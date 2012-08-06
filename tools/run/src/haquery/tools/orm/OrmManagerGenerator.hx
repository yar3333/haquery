package haquery.tools.orm;

import haquery.server.FileSystem;
import haquery.server.db.HaqDb;
import haquery.tools.FlashDevelopProject;
import haquery.tools.Log;
import haquery.tools.orm.HaxeClass;
import sys.io.File;
import sys.io.FileOutput;

using haquery.StringTools;

class OrmManagerGenerator 
{
	static public function make(db:HaqDb, log:Log, table:String, basePath:String, modelFullClassName:String, customManagerFullClassName:String, autoGenManagerFullClassName:String, project:FlashDevelopProject) : Void
	{
		basePath = basePath.replace('\\', '/').rtrim('/') + '/';
		
		log.start(table + " => " + customManagerFullClassName);
		
		var vars = OrmTools.fields2vars(db.connection.getFields(table));
		
		var autoGeneratedManager = getAutoGeneratedManager(db, table, vars, modelFullClassName, autoGenManagerFullClassName);
		File.saveContent(
			 basePath + autoGenManagerFullClassName.replace('.', '/') + '.hx'
			,"// This is autogenerated file. Do not edit!\n\n" + autoGeneratedManager.toString()
		);
		
		if (project.findFile(customManagerFullClassName.replace('.', '/') + '.hx') == null)
		{
			var customManager = getCustomManager(table, vars, modelFullClassName, customManagerFullClassName, autoGenManagerFullClassName);
			File.saveContent(basePath + customManagerFullClassName.replace('.', '/') + '.hx', customManager.toString());
		}
		
		log.finishOk();
	}
	
	static function getAutoGeneratedManager(db:HaqDb, table:String, vars:List<HaxeVar>, modelFullClassName:String, fullClassName:String, baseFullClassName:String=null) : HaxeClass
	{
		var model:HaxeClass = new HaxeClass(fullClassName, baseFullClassName);
		
		model.addImport('#if php php.db.ResultSet #elseif neko neko.db.ResultSet #end');
		model.addImport('haquery.server.Lib');
		
		model.addMethod('new', [], 'Void', '');
        
        model.addMethod('newModelFromParams', vars, modelFullClassName,
			 "var _obj = new " + modelFullClassName + "();\n"
			+Lambda.map(vars, function(v:HaxeVar) { return '_obj.' + v.haxeName + ' = ' + v.haxeName + ';'; } ).join('\n') + "\n"
			+"return _obj;",
			true
		);
		
		model.addMethod('newModelFromRow', [ OrmTools.createVar('d', 'Dynamic') ], modelFullClassName,
			 "var _obj = new " + modelFullClassName + "();\n"
			 +Lambda.map(vars, function(v:HaxeVar) { return '_obj.' + v.haxeName + " = Reflect.field(d, '" + v.haxeName + "');"; } ).join('\n') + "\n"
			+"return _obj;",
			true
		);
		
		var getVars = Lambda.filter(vars, function(v:HaxeVar) { return v.isKey; } );
		if (getVars.length > 0)
		{
			model.addMethod('get', getVars, modelFullClassName,
				"return getBySqlOne('SELECT * FROM `" + table + "`" + getWhereSql(getVars) + ");"
			);
		}
		
		var createVars = Lambda.filter(vars, function(v:HaxeVar) { return !v.isAutoInc; } );
        var foreignKeys = db.connection.getForeignKeys(table);
        var foreignKeyVars = Lambda.filter(vars, function(v:HaxeVar) { return !v.isAutoInc; } );
		model.addMethod('create', createVars, modelFullClassName,
            (
                Lambda.exists(createVars, function(v:HaxeVar) { return v.name == 'position'; } )
                ? "if (position == null)\n"
                 +"{\n"
                 +"\tposition = Lib.db.query('SELECT MAX(`position`) FROM `" + table + "`" 
                    +getWhereSql(getForeignKeyVars(db, table, vars))
                    +").getIntResult(0) + 1;\n"
                 +"}\n\n"
                : ""
            )
			+"Lib.db.query('INSERT INTO `" + table + "`("
				+Lambda.map(createVars, function(v) { return "`" + v.name + "`"; } ).join(", ")
			+") VALUES (' + "
				+Lambda.map(createVars, function(v) { return "Lib.db.quote(" + v.haxeName + ")"; } ).join(" + ', ' + ")
			+" + ')');\n"
			+"return newModelFromParams(" + Lambda.map(vars, function(v) { return v.isAutoInc ? 'Lib.db.lastInsertId()' : v.haxeName; } ).join(", ") + ");"
		);
		
		var deleteVars = Lambda.filter(vars, function(v:HaxeVar) { return v.isKey; } );
		if (deleteVars.length == 0) deleteVars = vars;
		model.addMethod('delete', deleteVars, 'Void',
			"Lib.db.query('DELETE FROM `" + table + "`" + getWhereSql(deleteVars) + " + ' LIMIT 1');"
		);
		
		model.addMethod('getAll', [ OrmTools.createVar('_order', 'String', getOrderDefVal(vars)) ], 'Array<'+modelFullClassName+'>',
			 "return getBySqlMany('SELECT * FROM `" + table + "`' + (_order != null ? ' ORDER BY ' + _order : ''));"
		);
		
		model.addMethod('getBySqlOne', [ OrmTools.createVar('sql', 'String') ], modelFullClassName,
			 "var rows : ResultSet = Lib.db.query(sql + ' LIMIT 1');\n"
			+"if (rows.length == 0) return null;\n"
			+"return newModelFromRow(rows.next());"
		);
		
		model.addMethod('getBySqlMany', [ OrmTools.createVar('sql', 'String') ], 'Array<'+modelFullClassName+'>',
			 "var rows : ResultSet = Lib.db.query(sql);\n"
			+"var list : Array<" + modelFullClassName + "> = [];\n"
			+"for (row in rows)\n"
			+"{\n"
			+"	list.push(newModelFromRow(row));\n"
			+"}\n"
			+"return list;"
		);
		
		var uniques = db.connection.getUniques(table);
        for (uniqueName in uniques.keys())
		{
			var uniqueFields = uniques.get(uniqueName);
            
            var vs = Lambda.filter(vars, function(v) { return Lambda.has(uniqueFields, v.name); } );
			createGetByMethodOne(table, vars, modelFullClassName, vs, model);
		}
		
        for (v in getForeignKeyVars(db, table, vars))
        {
            createGetByMethodMany(table, vars, modelFullClassName, [v], model);
        }
		
		return model;
	}
	
	static function getCustomManager(table:String, vars:List<HaxeVar>, modelFullClassName:String, fullClassName:String, baseFullClassName:String=null) : HaxeClass
	{
		var model:HaxeClass = new HaxeClass(fullClassName, baseFullClassName);
		
		model.addImport('haquery.server.Lib');
		model.addImport(modelFullClassName);
		
		return model;
	}
	
	static function createGetByMethodOne(table:String, vars:List<HaxeVar>, modelFullClassName:String, whereVars:List<HaxeVar>, model:HaxeClass) : Void
	{
		if (whereVars == null || whereVars.length == 0) return;
        
        model.addMethod(
			'getBy' + Lambda.map(whereVars, function(v) { return OrmTools.capitalize(v.haxeName); } ).join('And'),
			whereVars, 
			modelFullClassName,
			
			"return getBySqlOne('SELECT * FROM `" + table + "`" + getWhereSql(whereVars) + ");"
		);
	}
	
	static function createGetByMethodMany(table:String, vars:List<HaxeVar>, modelFullClassName:String, whereVars:Iterable<HaxeVar>, model:HaxeClass) : Void
	{
		if (whereVars == null || !whereVars.iterator().hasNext()) return;

		model.addMethod(
			'getBy' + Lambda.map(whereVars, function(v) { return OrmTools.capitalize(v.haxeName); } ).join('And'),
			Lambda.concat(whereVars, [ OrmTools.createVar('_order', 'String', getOrderDefVal(vars)) ]), 
			'Array<' + modelFullClassName + '>',
			
			"return getBySqlMany('SELECT * FROM `" + table + "`" + getWhereSql(whereVars) + " + (_order != null ? ' ORDER BY ' + _order : ''));"
		);
	}
	
	static function getOrderDefVal(vars:List<HaxeVar>) : String
	{
		var positionVar = Lambda.filter(vars, function(v) { return v.name == 'position'; } );
		return positionVar.isEmpty() ? 'null' : "'" + positionVar.first().haxeName + "'";
	}
    
    static function getWhereSql(vars:Iterable<HaxeVar>) : String
    {
        return vars.iterator().hasNext()
            ? " WHERE " + Lambda.map(vars, function(v) { return "`" + v.name + "` = ' + Lib.db.quote(" + v.haxeName + ")"; } ).join("+' AND ")
            : "'";
    }
    
    static function getForeignKeyVars(db:HaqDb, table:String, vars:List<HaxeVar>) : List<HaxeVar>
    {
        var foreignKeys = db.connection.getForeignKeys(table);
        var foreignKeyVars = Lambda.filter(vars, function(v:HaxeVar) {
            return Lambda.exists(foreignKeys, function(fk) { return fk.key == v.name; } );
        } );
        return foreignKeyVars;
    }

}
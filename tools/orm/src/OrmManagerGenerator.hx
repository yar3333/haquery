package ;

import php.FileSystem;
import php.io.File;
import php.io.FileOutput;
import php.Lib;
import haquery.server.db.HaqDb;
import haquery.server.db.HaqDbDriver;
import OrmHaxeClass;
using haquery.StringTools;

class OrmManagerGenerator 
{
	static public function make(table:String, basePath:String, modelFullClassName:String, customManagerFullClassName:String, autoGenManagerFullClassName:String) : Void
	{
		basePath = basePath.replace('\\', '/').rtrim('/') + '/';
		
		Lib.println("");
		Lib.println(table + " => " + customManagerFullClassName);
		
		var vars = OrmTools.fields2vars(HaqDb.connection.getFields(table));
		
		var autoGeneratedManager = getAutoGeneratedManager(table, vars, modelFullClassName, autoGenManagerFullClassName);
		File.putContent(basePath + autoGenManagerFullClassName.replace('.', '/') + '.hx', autoGeneratedManager.toString());
		
		var customManager = getCustomManager(table, vars, modelFullClassName, customManagerFullClassName, autoGenManagerFullClassName);
		var pathToCustomManager = basePath + customManagerFullClassName.replace('.', '/') + '.hx';
		if (!FileSystem.exists(pathToCustomManager)) 
		{
			File.putContent(pathToCustomManager, customManager.toString());
		}
	}
	
	static function getAutoGeneratedManager(table:String, vars:List<OrmHaxeVar>, modelFullClassName:String, fullClassName:String, baseFullClassName:String=null) : OrmHaxeClass
	{
		var model:OrmHaxeClass = new OrmHaxeClass(fullClassName, baseFullClassName);
		
		model.addImport('php.db.ResultSet');
		model.addImport('haquery.server.db.HaqDb');
		
		model.addMethod('new', [], 'Void', '');
        
        model.addMethod('newModelFromParams', vars, modelFullClassName,
			 "var _obj = new " + modelFullClassName + "();\n"
			+Lambda.map(vars, function(v:OrmHaxeVar) { return '_obj.' + v.haxeName + ' = ' + v.haxeName + ';'; } ).join('\n') + "\n"
			+"return _obj;",
			true
		);
		
		model.addMethod('newModelFromRow', [ OrmTools.createVar('d', 'Dynamic') ], modelFullClassName,
			 "var _obj = new " + modelFullClassName + "();\n"
			 +Lambda.map(vars, function(v:OrmHaxeVar) { return '_obj.' + v.haxeName + " = Reflect.field(d, '" + v.haxeName + "');"; } ).join('\n') + "\n"
			+"return _obj;",
			true
		);
		
		var getVars = Lambda.filter(vars, function(v:OrmHaxeVar) { return v.isKey; } );
		if (getVars.length > 0)
		{
			model.addMethod('get', getVars, modelFullClassName,
				"return getBySql('SELECT * FROM `" + table + "`" + getWhereSql(getVars) + ");"
			);
		}
		
		var createVars = Lambda.filter(vars, function(v:OrmHaxeVar) { return !v.isAutoInc; } );
        var foreignKeys = HaqDb.connection.getForeignKeys(table);
        var foreignKeyVars = Lambda.filter(vars, function(v:OrmHaxeVar) { return !v.isAutoInc; } );
		model.addMethod('create', createVars, modelFullClassName,
            (
                Lambda.exists(createVars, function(v:OrmHaxeVar) { return v.name == 'position'; } )
                ? "if (position == null)\n"
                 +"{\n"
                 +"\tposition = HaqDb.query('SELECT MAX(`position`) FROM `" + table + "`" 
                    +getWhereSql(getForeignKeyVars(table, vars))
                    +").getIntResult(0) + 1;\n"
                 +"}\n\n"
                : ""
            )
			+"HaqDb.query('INSERT INTO `" + table + "`("
				+Lambda.map(createVars, function(v) { return "`" + v.name + "`"; } ).join(", ")
			+") VALUES (' + "
				+Lambda.map(createVars, function(v) { return "HaqDb.quote(" + v.haxeName + ")"; } ).join(" + ', ' + ")
			+" + ')');\n"
			+"if (HaqDb.affectedRows() < 1) return null;\n"
			+"return newModelFromParams(" + Lambda.map(vars, function(v) { return v.isAutoInc ? 'HaqDb.lastInsertId()' : v.haxeName; } ).join(", ") + ");"
		);
		
		var deleteVars = Lambda.filter(vars, function(v:OrmHaxeVar) { return v.isKey; } );
		if (deleteVars.length == 0) deleteVars = vars;
		model.addMethod('delete', deleteVars, 'Void',
			"HaqDb.query('DELETE FROM `" + table + "`" + getWhereSql(deleteVars) + " + ' LIMIT 1');"
		);
		
		model.addMethod('getsAll', [ OrmTools.createVar('_order', 'String', getOrderDefVal(vars)) ], 'Array<'+modelFullClassName+'>',
			 "return getsBySql('SELECT * FROM `" + table + "`' + (_order != null ? ' ORDER BY ' + _order : ''));"
		);
		
		model.addMethod('getBySql', [ OrmTools.createVar('sql', 'String') ], modelFullClassName,
			 "var rows : ResultSet = HaqDb.query(sql + ' LIMIT 1');\n"
			+"if (rows.length == 0) return null;\n"
			+"return newModelFromRow(rows.next());"
		);
		
		model.addMethod('getsBySql', [ OrmTools.createVar('sql', 'String') ], 'Array<'+modelFullClassName+'>',
			 "var rows : ResultSet = HaqDb.query(sql);\n"
			+"var list : Array<" + modelFullClassName + "> = [];\n"
			+"for (row in rows)\n"
			+"{\n"
			+"	list.push(newModelFromRow(row));\n"
			+"}\n"
			+"return list;"
		);
		
		var uniques = HaqDb.connection.getUniques(table);
        for (uniqueName in uniques.keys())
		{
			var uniqueFields = uniques.get(uniqueName);
            
            var vs = Lambda.filter(vars, function(v) { return Lambda.has(uniqueFields, v.name); } );
			createGetByMethod(table, vars, modelFullClassName, vs, model);
		}
		
        for (v in getForeignKeyVars(table, vars))
        {
            createGetsByMethod(table, vars, modelFullClassName, [v], model);
        }
		
		return model;
	}
	
	static function getCustomManager(table:String, vars:List<OrmHaxeVar>, modelFullClassName:String, fullClassName:String, baseFullClassName:String=null) : OrmHaxeClass
	{
		var model:OrmHaxeClass = new OrmHaxeClass(fullClassName, baseFullClassName);
		var clas = OrmTools.splitFullClassName(fullClassName);
		
		model.addImport('haquery.server.db.HaqDb');
		model.addImport(modelFullClassName);
		
		return model;
	}
	
	static function createGetByMethod(table:String, vars:List<OrmHaxeVar>, modelFullClassName:String, whereVars:List<OrmHaxeVar>, model:OrmHaxeClass) : Void
	{
		if (whereVars == null || whereVars.length == 0) return;
        
        model.addMethod(
			'getBy' + Lambda.map(whereVars, function(v) { return OrmTools.capitalize(v.haxeName); } ).join('And'),
			whereVars, 
			modelFullClassName,
			
			"return getBySql('SELECT * FROM `" + table + "`" + getWhereSql(whereVars) + ");"
		);
	}
	
	static function createGetsByMethod(table:String, vars:List<OrmHaxeVar>, modelFullClassName:String, whereVars:Iterable<OrmHaxeVar>, model:OrmHaxeClass) : Void
	{
		if (whereVars == null || !whereVars.iterator().hasNext()) return;

		model.addMethod(
			'getsBy' + Lambda.map(whereVars, function(v) { return OrmTools.capitalize(v.haxeName); } ).join('And'),
			Lambda.concat(whereVars, [ OrmTools.createVar('_order', 'String', getOrderDefVal(vars)) ]), 
			'Array<' + modelFullClassName + '>',
			
			"return getsBySql('SELECT * FROM `" + table + "`" + getWhereSql(whereVars) + " + (_order != null ? ' ORDER BY ' + _order : ''));"
		);
	}
	
	static function getOrderDefVal(vars:List<OrmHaxeVar>) : String
	{
		var positionVar = Lambda.filter(vars, function(v) { return v.name == 'position'; } );
		return positionVar.isEmpty() ? 'null' : "'" + positionVar.first().haxeName + "'";
	}
    
    static function getWhereSql(vars:Iterable<OrmHaxeVar>) : String
    {
        return " WHERE " + Lambda.map(vars, function(v) { return "`" + v.name + "` = ' + HaqDb.quote(" + v.haxeName + ")"; } ).join("+' AND ");
    }
    
    static function getForeignKeyVars(table:String, vars:List<OrmHaxeVar>) : List<OrmHaxeVar>
    {
        var foreignKeys = HaqDb.connection.getForeignKeys(table);
        var foreignKeyVars = Lambda.filter(vars, function(v:OrmHaxeVar) {
            return Lambda.exists(foreignKeys, function(fk) { return fk.key == v.name; } );
        } );
        return foreignKeyVars;
    }

}
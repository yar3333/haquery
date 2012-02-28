package haquery.tools.orm;

import haquery.server.FileSystem;
import haquery.server.io.File;
import haquery.server.io.FileOutput;
import haquery.server.db.HaqDb;
import haquery.server.db.HaqDbDriver;
import haquery.tools.Log;
import haquery.tools.orm.HaxeClass;

using haquery.StringTools;

class OrmModelGenerator 
{
	static public function make(log:Log, table:String, basePath:String, customModelFullClassName:String, autoGenModelFullClassName:String, customManagerFullClassName:String) : Void
	{
		basePath = basePath.replace('\\', '/').rtrim('/') + '/';
		
		log.start(table + " => " + customModelFullClassName);
		
		var vars = OrmTools.fields2vars(HaqDb.connection.getFields(table));
		
		var autoGeneratedModel = getAutoGeneratedModel(table, vars, autoGenModelFullClassName);
		File.putContent(
			 basePath + autoGenModelFullClassName.replace('.', '/') + '.hx'
			,"// This is autogenerated file. Do not edit!\n\n" + autoGeneratedModel.toString()
		);
		
		var customModel = getCustomModel(table, vars, customModelFullClassName, autoGenModelFullClassName, customManagerFullClassName);
		var pathToCustomModel = basePath + customModelFullClassName.replace('.', '/') + '.hx';
		if (!FileSystem.exists(pathToCustomModel)) 
		{
			File.putContent(pathToCustomModel, customModel.toString());
		}
		
		log.finishOk();
	}
	
	static function getAutoGeneratedModel(table:String, vars:List<HaxeVar>, fullClassName:String, baseFullClassName:String=null) : HaxeClass
	{
		var model = new HaxeClass(fullClassName, baseFullClassName);
		
		model.addImport('haquery.server.db.HaqDb');
		
		for (v in vars)
		{
			model.addVar(v);
		}
		
        model.addMethod('new', [], 'Void', '');
        
        if (Lambda.exists(vars, function(v:HaxeVar) { return v.isKey; } ) && Lambda.exists(vars, function(v:HaxeVar) { return !v.isKey; } ))
		{
			var settedVars = Lambda.filter(vars, function(v:HaxeVar) { return !v.isKey && !v.isAutoInc; } );
			if (settedVars.length > 0)
			{
				model.addMethod('set', settedVars, 'Void',
					Lambda.map(settedVars, function(v:HaxeVar) { return 'this.' + v.haxeName + " = " + v.haxeName + ";"; }).join('\n')
				);
			}
			
			var savedVars = Lambda.filter(vars, function(v:HaxeVar) { return !v.isKey; } );
			var whereVars = Lambda.filter(vars, function(v:HaxeVar) { return v.isKey; } );
			model.addMethod('save', new List<HaxeVar>(), 'Void',
				 "HaqDb.query(\n"
				    +"\t 'UPDATE `" + table + "` SET '\n"
					+"\t\t+  '" + Lambda.map(savedVars, function(v:HaxeVar) { return "`" + v.name + "` = ' + HaqDb.quote(" + v.haxeName + ")"; }).join("\n\t\t+', ")
					+"\n\t+' WHERE " 
					+Lambda.map(whereVars, function(v:HaxeVar) { return "`" + v.name + "` = ' + HaqDb.quote(" + v.haxeName + ")"; } ).join("+' AND ")
					+"\n\t+' LIMIT 1'"
				+"\n);"
			);
		}
		
		return model;
	}

	static function getCustomModel(table:String, vars:List<HaxeVar>, fullClassName:String, baseFullClassName:String, customManagerFullClassName:String) : HaxeClass
	{
		var model:HaxeClass = new HaxeClass(fullClassName, baseFullClassName);
		
		model.addImport('haquery.server.db.HaqDb');
		model.addImport(customManagerFullClassName);
		
		model.addVar(OrmTools.createVar('manager', customManagerFullClassName, 'new ' + customManagerFullClassName + '()'), false, true);
		
		return model;
	}
}
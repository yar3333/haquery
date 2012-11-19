package orm;

import hant.PathTools;
import haquery.server.FileSystem;
import haquery.server.db.HaqDb;
import hant.Log;
import haxe.io.Path;
import sys.io.File;
import sys.io.FileOutput;
using haquery.StringTools;

class OrmModelGenerator 
{
	public static function make(log:Log, project:FlashDevelopProject, db:HaqDb, table:String, customModelFullClassName:String, autoGenModelFullClassName:String, customManagerFullClassName:String) : Void
	{
		var basePath = PathTools.path2normal(project.srcPath) + "/";
		
		log.start(table + " => " + customModelFullClassName);
		
		var vars = OrmTools.fields2vars(db.connection.getFields(table));
		
		var autoGeneratedModel = getAutoGeneratedModel(table, vars, autoGenModelFullClassName);
		var destFileName = basePath + autoGenModelFullClassName.replace('.', '/') + '.hx';
		FileSystem.createDirectory(Path.directory(destFileName));
		File.saveContent(
			 destFileName
			,"// This is autogenerated file. Do not edit!\n\n" + autoGeneratedModel.toString()
		);
		
		if (project.findFile(customModelFullClassName.replace('.', '/') + '.hx') == null) 
		{
			var customModel = getCustomModel(table, vars, customModelFullClassName, autoGenModelFullClassName, customManagerFullClassName);
			var destFileName = basePath + customModelFullClassName.replace('.', '/') + '.hx';
			FileSystem.createDirectory(Path.directory(destFileName));
			File.saveContent(destFileName, customModel.toString());
		}
		
		log.finishOk();
	}
	
	static function getAutoGeneratedModel(table:String, vars:List<OrmHaxeVar>, fullClassName:String, baseFullClassName:String=null) : HaxeClass
	{
		var model = new HaxeClass(fullClassName, baseFullClassName);
		
		model.addImport('haquery.server.Lib');
		
		for (v in vars)
		{
			model.addVar(v);
		}
		
        model.addMethod('new', [], 'Void', '');
        
        if (Lambda.exists(vars, function(v:OrmHaxeVar) { return v.isKey; } ) && Lambda.exists(vars, function(v:OrmHaxeVar) { return !v.isKey; } ))
		{
			var settedVars = Lambda.filter(vars, function(v:OrmHaxeVar) { return !v.isKey && !v.isAutoInc; } );
			if (settedVars.length > 0)
			{
				model.addMethod('set', settedVars, 'Void',
					Lambda.map(settedVars, function(v:OrmHaxeVar) { return 'this.' + v.haxeName + " = " + v.haxeName + ";"; }).join('\n')
				);
			}
			
			var savedVars = Lambda.filter(vars, function(v:OrmHaxeVar) { return !v.isKey; } );
			var whereVars = Lambda.filter(vars, function(v:OrmHaxeVar) { return v.isKey; } );
			model.addMethod('save', new List<OrmHaxeVar>(), 'Void',
				 "Lib.db.query(\n"
				    +"\t 'UPDATE `" + table + "` SET '\n"
					+"\t\t+  '" + Lambda.map(savedVars, function(v:OrmHaxeVar) { return "`" + v.name + "` = ' + Lib.db.quote(" + v.haxeName + ")"; }).join("\n\t\t+', ")
					+"\n\t+' WHERE " 
					+Lambda.map(whereVars, function(v:OrmHaxeVar) { return "`" + v.name + "` = ' + Lib.db.quote(" + v.haxeName + ")"; } ).join("+' AND ")
					+"\n\t+' LIMIT 1'"
				+"\n);"
			);
		}
		
		return model;
	}

	static function getCustomModel(table:String, vars:List<OrmHaxeVar>, fullClassName:String, baseFullClassName:String, customManagerFullClassName:String) : HaxeClass
	{
		var model:HaxeClass = new HaxeClass(fullClassName, baseFullClassName);
		
		model.addImport('haquery.server.Lib');
		
		model.addVar(OrmTools.createVar('manager', customManagerFullClassName, 'new ' + customManagerFullClassName + '()'), false, true);
		
		return model;
	}
}
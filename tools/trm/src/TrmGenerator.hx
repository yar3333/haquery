package ;

import haquery.CompileStageComponentTemplateParser;
import haquery.server.HaqConfig;
import haquery.server.HaqDefines;
//import haquery.server.HaqTemplates;
import haquery.server.HaqXml;
import php.FileSystem;
import php.io.File;
import php.Lib;
import TrmHaxeClass;

using haquery.StringTools;

class TrmGenerator
{
	static inline var MIN_DATE = new Date(2000, 0, 0, 0, 0, 0);
	static var isFirstPrint = true; 
	
	public static function makeForComponents()
    {
		for (classPath in TrmTools.getClassPaths())
		{
			if (FileSystem.isDirectory(classPath + HaqDefines.folders.components))
			{
				for (collection in FileSystem.readDirectory(classPath + HaqDefines.folders.components))
				{
					for (tag in FileSystem.readDirectory(classPath + HaqDefines.folders.components + '/' + collection))
					{
						makeForComponent(classPath, collection, tag);
					}
				}
			}
		}
    }
	
	static function makeForComponent(classPath:String, collection:String, tag:String)
	{
		trace("TrmGenerator.makeForComponent('" + classPath + "', '" + collection + "', '" + tag + "')");
		
		var componentPath = HaqDefines.folders.components + "/" + collection + "/" + tag + "/";
		var destFilePath = classPath + componentPath + "Template.hx";
		var componentData = getComponentData(collection, tag);
		
		if (findFile(componentPath + "Server.hx") != null
		 || findFile(componentPath + "Client.hx") != null)
		{
			if (!FileSystem.exists(destFilePath) || FileSystem.stat(destFilePath).mtime.getTime() < componentData.lastMod.getTime())
			{
				var haxeClass = new TrmHaxeClass(HaqDefines.folders.components + "." + collection + "." + tag + ".Template", componentData.superClass);
				
				haxeClass.addVar(TrmTools.createVar("component", "#if php haquery.server.HaqComponent #else haquery.client.HaqComponent #end"), true);
				
				var doc = new HaqXml(componentData.templateText);
				var templateVars = getTemplateVars(collection, doc);
				if (templateVars.length > 0)
				{
					if (isFirstPrint)
					{
						Lib.print("\n  ");
						isFirstPrint = false;
					}
					Lib.print(collection + "." + tag + "\n  ");
					
					for (templateVar in templateVars)
					{
						haxeClass.addVarGetter(templateVar, false, false, true);
					}
					
					haxeClass.addMethod(
						 "new"
						,[ TrmTools.createVar("component", "#if php haquery.server.HaqComponent #else haquery.client.HaqComponent #end") ]
						,"Void"
						,"this.component = component;"
					);
					
					File.putContent(
						 destFilePath
						,"// This is autogenerated file. Do not edit!\n\n" + haxeClass.toString()
					);
				}
				else
				{
					if (FileSystem.exists(destFilePath))
					{
						FileSystem.deleteFile(destFilePath);
					}
				}
			}
		}
	}
	
	static function findFile(relativePath:String) : String
	{
		var classPaths = TrmTools.getClassPaths();
		var i = classPaths.length - 1;
		while (i >= 0)
		{
			if (FileSystem.exists(classPaths[i] + relativePath))
			{
				return classPaths[i] + relativePath;
			}
			i--;
		}
		return null;
	}
	
	static function getComponentData(collection:String, tag:String) : { templateText:String, superClass:String, lastMod:Date }
	{
		//trace("\ngetComponentData('" + componentsPackage + "', '" + componentName + "')");
		
		var componentsPackage = HaqDefines.folders.components + '.' + collection;
		
		var templateSuperClassPath = findFile(componentsPackage.replace(".", "/") + tag + "/Template.hx");
		if (templateSuperClassPath != null)
		{
			return { 
				  templateText : ""
				, superClass : componentsPackage + "." + tag
				, lastMod : MIN_DATE
			};
		}
		
		var templatePath = findFile(componentsPackage.replace(".", "/") + "/" + tag + "/template.html");
		var templateText = templatePath != null ? File.getContent(templatePath) : "";
		var lastMod = templatePath != null ? FileSystem.stat(templatePath).mtime : MIN_DATE;
		
		var extendsCollection =  new CompileStageComponentTemplateParser(TrmTools.getClassPaths(), collection, tag).config.extendsCollection;
		if (extendsCollection != null && extendsCollection != "")
		{
			var superTemplateData = getComponentData(extendsCollection, tag);
			return { 
				  templateText : superTemplateData.templateText + templateText
				, superClass : superTemplateData.superClass 
				, lastMod : superTemplateData.lastMod.getTime() > lastMod.getTime() ?  superTemplateData.lastMod : lastMod
			};
		}
		
		return {
			  templateText : templateText
			, superClass : null 
			, lastMod : MIN_DATE
		};
	}
	
	static function getTemplateVars(collection:String, node:HaqXmlNodeElement) : Array<TrmHaxeVarGetter>
	{
		var r : Array<TrmHaxeVarGetter> = [];
		var children : Array<HaqXmlNodeElement> = cast Lib.toHaxeArray(node.children);
		for (child in children)
		{
			if (child.hasAttribute("id") && child.getAttribute("id").trim() != "")
			{
				var componentID = child.getAttribute("id").trim();
				
				var type = "#if php haquery.server.HaqQuery #else haquery.client.HaqQuery #end";
				var body = "return component.q('#" + componentID + "');";
				if (child.name.startsWith("haq:"))
				{
					var componentName = child.name.substr("haq:".length);
					
					var parser = new CompileStageComponentTemplateParser(TrmTools.getClassPaths(), collection, componentName);
					var serverClassName = parser.getServerClassName();
					var clientClassName = parser.getClientClassName();
					
					type = "#if php " + serverClassName + " #else " + clientClassName + " #end";
					body = "return cast component.components.get('" + componentID + "');";
				}
				
				r.push({ name:componentID, type:type, body:body });
			}
			
			r = r.concat(getTemplateVars(collection, child));
		}
		return r;
	}
}

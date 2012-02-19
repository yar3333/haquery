package haquery.tools.trm;

import haquery.server.FileSystem;
import haquery.server.HaqDefines;
import haquery.server.HaqXml;
import haquery.server.io.File;
import haquery.server.Lib;

import haquery.tools.HaqTemplate;
import haquery.tools.HaqTemplateParser;
import haquery.tools.HaqTemplateManager;
import haquery.tools.HaxeClass;

using haquery.StringTools;
using haquery.HashTools;

class TrmGenerator
{
	var isFirstPrint : Bool; 
	
	var manager : HaqTemplateManager;
	
	public static function run(classPaths:Array<String>)
	{
		new TrmGenerator(classPaths);
	}
	
	function new(classPaths:Array<String>)
    {
		isFirstPrint = true;
		
		manager = new HaqTemplateManager(classPaths);
		
		for (fullTag in manager.templates.keys())
		{
			generate(fullTag);
		}
    }
	
	function generate(fullTag:String)
	{
		//trace("Generate TRM for " + fullTag);
		
		var template = manager.templates.get(fullTag);
		
		if (template.hasLocalServerClass || template.hasLocalClientClass)
		{
			if (!FileSystem.exists(template.trmFilePath) || FileSystem.stat(template.trmFilePath).mtime.getTime() < template.docLastMod.getTime())
			{
				var haxeClass = new HaxeClass(fullTag + ".Template");
				
				haxeClass.addVar(createVar("component", "#if php haquery.server.HaqComponent #else haquery.client.HaqComponent #end"), true);
				
				var templateVars = getTemplateVars(fullTag, template.doc);
				if (templateVars.length > 0)
				{
					if (isFirstPrint)
					{
						Lib.print("\n  ");
						isFirstPrint = false;
					}
					Lib.print(fullTag + "\n  ");
					
					for (templateVar in templateVars)
					{
						haxeClass.addVarGetter(templateVar, false, false, true);
					}
					
					haxeClass.addMethod(
						 "new"
						,[ createVar("component", "#if php haquery.server.HaqComponent #else haquery.client.HaqComponent #end") ]
						,"Void"
						,"this.component = component;"
					);
					
					File.putContent(
						 template.trmFilePath
						,"// This is autogenerated file. Do not edit!\n\n" + haxeClass.toString()
					);
				}
				else
				{
					if (FileSystem.exists(template.trmFilePath))
					{
						FileSystem.deleteFile(template.trmFilePath);
					}
				}
			}
		}
	}
	
	/*static function findFile(classPaths:Array<String>, relativePath:String) : String
	{
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
	}*/
	
	// TODO: rewrite to HaqTemplateParser
	/*static function getComponentData(classPaths:Array<String>, fullTag:String) : { templateText:String, superClass:String, lastMod:Date }
	{
		//trace("\ngetComponentData('" + componentsPackage + "', '" + componentName + "')");
		
		var templateSuperClassPath = findFile(classPaths, fullTag.replace(".", "/") + "/Template.hx");
		if (templateSuperClassPath != null)
		{
			return { 
				  templateText : ""
				, superClass : fullTag
				, lastMod : MIN_DATE
			};
		}
		
		var templatePath = findFile(classPaths, fullTag.replace(".", "/") + "/template.html");
		var templateText = templatePath != null ? File.getContent(templatePath) : "";
		var lastMod = templatePath != null ? FileSystem.stat(templatePath).mtime : MIN_DATE;
		
		var extend = new HaqTemplateParser(TrmTools.getClassPaths(), fullTag).getExtend();
		if (extend != null && extend != "")
		{
			var superTemplateData = getComponentData(classPaths, extend);
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
	}*/
	
	function getTemplateVars(fullTag:String, node:HaqXmlNodeElement) : Array<HaxeVarGetter>
	{
		var r : Array<HaxeVarGetter> = [];
		var children = node.children;
		for (child in children)
		{
			if (child.hasAttribute("id") && child.getAttribute("id").trim() != "")
			{
				var componentID = child.getAttribute("id").trim();
				
				var type = "#if php haquery.server.HaqQuery #else haquery.client.HaqQuery #end";
				var body = "return component.q('#" + componentID + "');";
				if (child.name.startsWith("haq:"))
				{
					var template = manager.findTemplate(fullTag, child.name.substr("haq:".length));
					if (template == null)
					{
						trace("Component not found: fullTag = " + fullTag + ", tag = " + child.name.substr("haq:".length));
						Lib.assert(template != null);
					}
					
					type = "#if php " + template.serverClassName + " #else " + template.clientClassName + " #end";
					body = "return cast component.components.get('" + componentID + "');";
				}
				
				r.push({ haxeName:componentID, haxeType:type, haxeBody:body });
			}
			
			r = r.concat(getTemplateVars(fullTag, child));
		}
		return r;
	}
	
	static function createVar(name:String, type:String, defVal:String = null) : HaxeVar
	{
		return {
			 haxeName : name
			,haxeType : type
			,haxeDefVal : defVal
		};
	}	
}
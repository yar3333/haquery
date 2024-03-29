import hant.FileSystemTools;
import haquery.common.HaqComponentTools;
import haxe.io.Path;
import htmlparser.HtmlNodeElement;
import sys.FileSystem;
import sys.io.File;
import HaxeClass;
using stdlib.StringTools;

enum HaxeClassField
{
	VarGetter(v:HaxeVarGetter);
	Var(v:HaxeVar);
}

class TrmGenerator
{
	var manager : HaqTemplateManager;
	
	public static function run(manager:HaqTemplateManager)
	{
		new TrmGenerator(manager);
	}
	
	function new(manager:HaqTemplateManager)
    {
		this.manager = manager;
		
		for (fullTag in manager.fullTags)
		{
			generate(fullTag);
		}
    }
	
	function generate(fullTag:String)
	{
		var template = manager.get(fullTag);
		
		if (template.hasLocalServerClass)
		{
			generateTypedefFile(
				  fullTag + ".BaseServer"
				, template.genBaseServerFilePath
				, template.baseServerClass
			);
		}
		else
		{
			FileSystemTools.deleteFile(template.genBaseServerFilePath);
		}
		
		if (template.hasLocalClientClass)
		{
			generateTypedefFile(
				  fullTag + ".BaseClient"
				, template.genBaseClientFilePath
				, template.baseClientClass
			);
		}
		else
		{
			FileSystemTools.deleteFile(template.genBaseClientFilePath);
		}
		
		if (template.hasLocalServerClass || template.hasLocalClientClass)
		{
			var serverVars = getTemplateVars(fullTag, template.doc, "haquery.server.HaqQuery", true);
			if (serverVars.length > 0 && template.hasLocalServerClass)
			{
				generateTrmClass(serverVars, fullTag + ".TemplateServer", template.genTemplateServerFilePath, "haquery.server.HaqComponent");
			}
			else
			{
				FileSystemTools.deleteFile(template.genTemplateServerFilePath);
			}
				
			var clientVars = getTemplateVars(fullTag, template.doc, "haquery.client.HaqQuery", false);
			if (clientVars.length > 0 && template.hasLocalClientClass)
			{
				generateTrmClass(clientVars, fullTag + ".TemplateClient", template.genTemplateClientFilePath, "haquery.client.HaqComponent");
			}
			else
			{
				FileSystemTools.deleteFile(template.genTemplateClientFilePath);
			}
		}
	}
	
	function generateTypedefFile(className:String, classFilePath:String, extend:String)
	{
		var pack = className.substr(0, className.lastIndexOf("."));
		var name = className.substr(className.lastIndexOf(".") + 1);
		
		FileSystemTools.createDirectory(Path.directory(classFilePath));
		
		saveContentToFileIfNeed(classFilePath
			, "// This is autogenerated file. Do not edit!\n\n" 
			+ "package " + pack + ";\n\n"
			+ "typedef " + name + " = " + (extend + ";\n")
		);
	}
	
	function generateTrmClass(vars:Array<HaxeClassField>, className:String, classFilePath:String, stdComponentClassName:String)
	{
		var haxeClass = new HaxeClass(className);
		
		haxeClass.addMeta("@:access(" + stdComponentClassName + ")");
		
		haxeClass.addVar(createVar("component", stdComponentClassName), true);
		
		for (v in vars)
		{
			switch (v)
			{
				case HaxeClassField.VarGetter(vv):
					haxeClass.addVarGetter(vv, false, false, true);
				
				case HaxeClassField.Var(vv):
					haxeClass.addVar(vv, true, false);
			}
		}
		
		haxeClass.addMethod(
			 "new"
			,[ createVar("component", stdComponentClassName) ]
			,"Void"
			,"this.component = component;"
		);
		
		FileSystemTools.createDirectory(Path.directory(classFilePath));
		
		saveContentToFileIfNeed(classFilePath, "// This is autogenerated file. Do not edit!\n\n" + haxeClass.toString());
	}
	
	function getTemplateVars(fullTag:String, node:HtmlNodeElement, queryClassName:String, isServer:Bool, isFactoryInner=false) : Array<HaxeClassField>
	{
		var r : Array<HaxeClassField> = [];
		var children = node.children;
		for (child in children)
		{
			if (child.hasAttribute("id") && child.getAttribute("id").trim() != "")
			{
				var componentID = child.getAttribute("id").trim();
				
				if (~/^[_a-zA-Z][_a-zA-Z0-9]*$/.match(componentID))
				{
					var type = queryClassName;
					var body = "return component.q('#" + componentID + "');";
					if (child.name.startsWith("haq:"))
					{
						var tag = HaqComponentTools.htmlTagToFullTag(child.name.substr("haq:".length));
						var template = manager.get(tag);
						type = isServer ? template.serverClassName : template.clientClassName;
						body = "return cast component.components.get('" + componentID + "');";
					}
					
					if (!isFactoryInner)
					{
						r.push(HaxeClassField.VarGetter( { haxeName:componentID, haxeType:type, haxeBody:body } ));
					}
					else
					{
						r.push(HaxeClassField.Var( { haxeName:componentID, haxeType:type, haxeDefVal:null } ));
					}
				}
			}
			
			r = r.concat(getTemplateVars(fullTag, child, queryClassName, isServer, isFactoryInner || isFactoryNode(fullTag, child.name)));
		}
		return r;
	}
	
	function createVar(name:String, type:String, defVal:String = null) : HaxeVar
	{
		return {
			 haxeName : name
			,haxeType : type
			,haxeDefVal : defVal
		};
	}
	
	function isFactoryNode(fullTag:String, nodeName:String)
	{
		if (nodeName.startsWith("haq:"))
		{
			var tag = HaqComponentTools.htmlTagToFullTag(nodeName.substr("haq:".length));
			var template = manager.get(tag);
			while (template != null)
			{
				if (template.fullTag == "components.haquery.list")
				{
					return true;
				}
				template = template.extend != "" ? manager.get(template.extend) : null;
			}
		}
		return false;
	}
	
	function saveContentToFileIfNeed(file:String, content:String)
	{
		if (!FileSystem.exists(file) || File.getContent(file) != content)
		{
			File.saveContent(file, content);
		}
	}
}

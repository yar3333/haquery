package ;

import hant.Log;
import haquery.common.HaqComponentTools;
import haquery.common.HaqDefines;
import haquery.common.HaqTemplateExceptions;
import haquery.Exception;
import haquery.server.FileSystem;
import haxe.htmlparser.HtmlNodeElement;
import haxe.io.Path;
import haxe.Serializer;
import sys.io.File;
using haquery.StringTools;

class PathNotFoundException extends Exception {}

class HaqTemplateManager extends haquery.base.HaqTemplateManager<HaqTemplate>
{
	var classPaths : Array<String>;
	
	var log : Log;
	
	public var fullTags(default, null) : Hash<Int>;
	
	public function new(log:Log, classPaths:Array<String>)
	{
		super();
		
		this.classPaths = classPaths;
		this.log = log;
		
		fillTemplates(HaqDefines.folders.pages);
		
		for (template in templates)
		{
			resolveComponentTags(template, template.doc);
		}
		
		// exclude unused components
		fullTags = getUsedComponents();
		for (fullTag in templates.keys())
		{
			if (!fullTags.exists(fullTag))
			{
				templates.remove(fullTag);
			}
		}
	}
	
	override function newTemplate(fullTag:String) : HaqTemplate
	{
		return new HaqTemplate(log, classPaths, fullTag); 
	}
	
	function fillTemplates(pack:String)
	{
		var localPath = pack.replace(".", "/");
		
		var pathWasFound = false;
		
		var i = classPaths.length - 1;
		while (i >= 0)
		{
			var path = classPaths[i] + localPath;
			if (FileSystem.exists(path) && FileSystem.isDirectory(path))
			{
				pathWasFound = true;
				for (file in FileSystem.readDirectory(path))
				{
					if (file != HaqDefines.folders.support && FileSystem.isDirectory(path + '/' + file))
					{
						addTemplate(pack + "." + file);
					}
				}
			}
			i--;
		}
		
		if (!pathWasFound)
		{
			throw new PathNotFoundException("Components path '" + localPath + "' not found.");
		}
	}
	
	function addTemplate(fullTag:String)
	{
		if (fullTag != null && fullTag != "" && !templates.exists(fullTag))
		{
			try
			{
				var template = new HaqTemplate(log, classPaths, fullTag);
				templates.set(fullTag, template);
				
				addTemplate(template.extend);
				
				for (imp in template.imports)
				{
					if (imp.asTag == null)
					{
						fillTemplates(imp.component);
					}
					else
					{
						addTemplate(imp.component);
					}
				}
			}
			catch (e:HaqTemplateNotFoundException)
			{
				fillTemplates(fullTag);
			}
		}
	}
	
	function getUsedComponents() : Hash<Int>
	{
		var userComponents = new Hash<Int>();
		for (fullTag in templates.keys())
		{
			if (fullTag.startsWith(HaqDefines.folders.pages + "."))
			{
				getUsedComponents_addToUsed(get(fullTag), userComponents);
			}
		}
		return userComponents;
	}
	
	function getUsedComponents_addToUsed(template:HaqTemplate, userComponents:Hash<Int>)
	{
		if (template != null && !userComponents.exists(template.fullTag))
		{
			userComponents.set(template.fullTag, 1);
			
			if (template.extend != null && template.extend != "")
			{
				getUsedComponents_addToUsed(get(template.extend), userComponents);
			}
			
			for (require in template.requires)
			{
				getUsedComponents_addToUsed(get(require), userComponents);
			}
			
			for (tag in getUsedComponents_getDocTags(template.doc))
			{
				getUsedComponents_addToUsed(get(tag), userComponents);
			}
		}
	}
	
	function getUsedComponents_getDocTags(doc:HtmlNodeElement) : Array<String>
	{
		var r = [];
		for (node in doc.children)
		{
			if (node.name.startsWith("haq:"))
			{
				r.push(HaqComponentTools.htmlTagToFullTag(node.name.substr("haq:".length)));
			}
			r = r.concat(getUsedComponents_getDocTags(node));
		}
		return r;
	}
	
	function getFullPath(path:String)
	{
		var i = classPaths.length - 1;
		while (i >= 0)
		{
			var fullPath = classPaths[i] + path;
			if (FileSystem.exists(fullPath))
			{
				return fullPath;
			}
			i--;
		}
		return null;
	}
	
	/*public function getStaticTemplateDataForJs() : String
	{
		var r = "\nhaquery.client.HaqInternals.templates = haquery.HashTools.hashify({\n";
		r += Lambda.map({ iterator:templates.keys }, function(fullTag) {
			var template = get(fullTag);
			var importsParam = "[" + Lambda.map(template.imports, function(s) return "'" + s + "'").join(",") + "]";
			return "'" + fullTag + "' : new haquery.client.HaqTemplate('" + fullTag + "')";
		}).join(",\n");
		r += "\n});\n";
		return r;
	}*/
	
	public function getLastMods() : Hash<Date>
	{
		var r = new Hash<Date>();
		for (fullTag in templates.keys())
		{
			r.set(fullTag, templates.get(fullTag).lastMod);
		}
		return r;
	}
	
	function resolveComponentTags(parent:HaqTemplate, doc:HtmlNodeElement)
	{
		for (node in doc.children)
		{
			if (node.name.startsWith("haq:"))
			{
				var tag = node.name.substr("haq:".length).replace("-", ".");
				
				var baseTemplate = resolveComponentTag(get(node.getAttribute("__parent")), tag);
				if (baseTemplate == null)
				{
					throw new HaqTemplateNotFoundCriticalException("Component '" + tag + "' used in '" + node.getAttribute("__parent") + "' can not be resolved.");
				}
				
				var realTemplate = resolveComponentTag(parent, tag);
				if (realTemplate == null)
				{
					throw new HaqTemplateNotFoundCriticalException("Component '" + tag + "' used in '" + parent.fullTag + "' can not be resolved.");
				}
				
				if (!isTemplateExtends(realTemplate, baseTemplate))
				{
					throw new HaqTemplateNotFoundCriticalException("Component '" + tag + "' (resolved as '" + realTemplate.fullTag + "') used in '" + parent.fullTag + "' must be extended from '" + baseTemplate.fullTag + "'.");
				}
				
				node.removeAttribute("__parent");
				node.name = "haq:" + HaqComponentTools.fullTagToHtmlTag(realTemplate.fullTag);
			}
			
			resolveComponentTags(parent, node);
		}
	}
	
	function resolveComponentTag(parent:HaqTemplate, tag:String) : HaqTemplate
	{
		if (tag.indexOf(".") >= 0)
		{
			return get(HaqDefines.folders.components + "." + tag);
		}
	
		for (imp in get(parent.fullTag).imports)
		{
			if (imp.asTag != null)
			{
				if (imp.asTag == tag)
				{
					return get(imp.component);
				}
			}
			else 
			{
				var template = get(imp.component + "." + tag);
				if (template != null)
				{
					return template;
				}
			}
		}
		
		return null;
	}
	
	function isTemplateExtends(realTemplate:HaqTemplate, baseTemplate:HaqTemplate)
	{
		if (realTemplate == null || baseTemplate == null) return false;
		if (realTemplate.fullTag == baseTemplate.fullTag) return true;
		if (realTemplate.extend == null || realTemplate.extend == "") return false;
		return isTemplateExtends(get(realTemplate.extend), baseTemplate);
	}
	
	public function generateConfigClasses()
	{
		for (fullTag in fullTags.keys())
		{
			var template = get(fullTag);
			var path = "gen/" + fullTag.replace(".", "/");
			log.trace(path);
			FileSystem.createDirectory(Path.directory(path));
			File.saveContent(path + "/ConfigServer.hx"
				, "// This is autogenerated file. Do not edit!\n\n"
				+ "package " + fullTag + ";\n\n"
				+ "@:keep class ConfigServer\n"
				+ "{\n"
				+ "\tpublic static var extend = '" + template.extend + "';\n"
				+ "\tpublic static var serverClassName = '" + template.serverClassName + "';\n"
				+ "\tpublic static var clientClassName = '" + template.clientClassName + "';\n"
				+ "\tpublic static var serializedDoc = '" + Serializer.run(template.doc) + "';\n"
				+ "}\n"
			);
			
			File.saveContent(path + "/ConfigClient.hx"
				, "// This is autogenerated file. Do not edit!\n\n"
				+ "package " + fullTag + ";\n\n"
				+ "@:keep class ConfigClient\n"
				+ "{\n"
				+ "\tpublic static var clientClassName = '" + template.clientClassName + "';\n"
				+ "\t// SERVER_HANDLERS\n"
				+ "}\n"
			);
		}
	}
	
	public function generateComponentsCssFile(binDir:String)
	{
		var dir = binDir + "/haquery/client";
		FileSystem.createDirectory(dir);
		
		var text = "";
		for (fullTag in templates.keys())
		{
			var template = get(fullTag);
			if (template.css.length > 0)
			{
				text += "/" + "* " + fullTag + "*" + "/\n" + template.css + "\n\n";
			}
		}
		
		File.saveContent(dir + "/haquery.css", text);
	}
}

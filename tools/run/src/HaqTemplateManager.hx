package ;

import hant.Log;
import haquery.common.HaqComponentTools;
import haquery.base.HaqTemplateParser.HaqTemplateNotFoundException;
import haquery.common.HaqDefines;
import haquery.server.FileSystem;
import haxe.htmlparser.HtmlNodeElement;
using haquery.StringTools;

class HaqTemplateManager extends haquery.base.HaqTemplateManager<HaqTemplate>
{
	var classPaths : Array<String>;
	
	var log : Log;
	
	public var fullTags(default, null) : Hash<Int>;
	
	public function new(classPaths:Array<String>, log:Log)
	{
		super();
		
		this.classPaths = classPaths;
		this.log = log;
		
		fillTemplates(HaqDefines.folders.pages);
		
		// exclude unused components
		fullTags = getUsedComponents();
		for (fullTag in templates.keys())
		{
			if (!fullTags.exists(fullTag))
			{
				templates.remove(fullTag);
			}
		}
		
		for (template in templates)
		{
			checkMaps(template.doc, template.maps);
		}
	}
	
	override function newTemplate(fullTag:String) : HaqTemplate
	{
		return new HaqTemplate(classPaths, fullTag); 
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
			log.trace("WARNING: imported components package '" + pack + "' not found.");
		}
	}
	
	function addTemplate(fullTag:String)
	{
		if (fullTag != null && fullTag != "" && !templates.exists(fullTag))
		{
			try
			{
				var template = new HaqTemplate(classPaths, fullTag);
				templates.set(fullTag, template);
				
				addTemplate(template.extend);
				
				for (importPack in template.imports)
				{
					fillTemplates(importPack);
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
				getUsedComponents_addToUsed(findTemplate(template.fullTag, tag), userComponents);
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
				r.push(HaqComponentTools.tag2pack(node.name.substr("haq:".length)));
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
	
	public function getStaticTemplateDataForJs() : String
	{
		var r = "\nhaquery.client.HaqInternals.templates = haquery.HashTools.hashify({\n";
		r += Lambda.map({ iterator:templates.keys }, function(fullTag) {
			var template = get(fullTag);
			var importsParam = "[" + Lambda.map(template.imports, function(s) return "'" + s + "'").join(",") + "]";
			return "'" + fullTag + "' : new haquery.client.HaqTemplate(" + importsParam + ", '" + template.clientClassName + "')";
		}).join(",\n");
		r += "\n});\n";
		return r;
	}
	
	public function getLastMods() : Hash<Date>
	{
		var r = new Hash<Date>();
		for (fullTag in templates.keys())
		{
			r.set(fullTag, templates.get(fullTag).lastMod);
		}
		return r;
	}
	
	function checkMaps(doc:HtmlNodeElement, maps:Hash<Array<String>>)
	{
		for (node in doc.children)
		{
			//if (node.
		}
	}
}
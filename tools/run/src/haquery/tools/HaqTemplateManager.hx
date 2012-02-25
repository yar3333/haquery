package haquery.tools;

import haquery.server.FileSystem;
import haquery.server.io.File;
import haquery.server.HaqDefines;

import haquery.tools.HaqTemplate;
import haquery.base.HaqTemplateParser.HaqTemplateNotFoundException;

import haquery.server.Lib;
import haquery.server.HaqXml;

using haquery.StringTools;
using haquery.HashTools;

class HaqTemplateManager extends haquery.base.HaqTemplateManager<HaqTemplate>
{
	var classPaths : Array<String>;
	
	public var unusedTemplates(default,null) : Array<String>;
	
	var isFirstPrint : Bool;
	
	public function new(classPaths:Array<String>)
	{
		super();
		
		this.classPaths = classPaths;
		
		isFirstPrint = true;
		
		fillTemplates(HaqDefines.folders.pages);
		unusedTemplates = detectUnusedTemplates();
	}
	
	override function newTemplate(fullTag:String) : HaqTemplate
	{
		return new HaqTemplate(classPaths, fullTag); 
	}
	
	function fillTemplates(pack:String)
	{
		var path = getFullPath(pack.replace(".", "/"));
		if (path != null)
		{
			for (file in FileSystem.readDirectory(path))
			{
				if (file != HaqDefines.folders.support && FileSystem.isDirectory(path + '/' + file))
				{
					var fullTag = pack + "." + file;
					
					if (!templates.exists(fullTag))
					{
						try
						{
							var template = new HaqTemplate(classPaths, fullTag);
							templates.set(fullTag, template);
							
							for (importPack in template.imports)
							{
								fillTemplates(importPack);
							}
						}
						catch (e:HaqTemplateNotFoundException)
						{
							if ((pack.replace(".", "/") + "/").startsWith(HaqDefines.folders.pages + '/'))
							{
								fillTemplates(fullTag);
							}
						}
					}
				}
			}
		}
		else
		{
			if (isFirstPrint)
			{
				Lib.print("\n  ");
				isFirstPrint = false;
			}
			Lib.print("WARNING: imported components package '" + pack + "' not found.\n  ");
		}
	}
	
	function detectUnusedTemplates() : Array<String>
	{
		var usedFullTags = new Hash<Int>();
		for (fullTag in templates.keys())
		{
			if (fullTag.startsWith(HaqDefines.folders.pages.replace("/", ".") + "."))
			{
				detectUnusedTemplates_addToUsed(get(fullTag), usedFullTags);
			}
		}
		
		var r = [];
		for (fullTag in templates.keys())
		{
			if (!usedFullTags.exists(fullTag))
			{
				r.push(fullTag);
			}
		}
		return r;
	}
	
	function detectUnusedTemplates_addToUsed(template:HaqTemplate, usedFullTags:Hash<Int>)
	{
		if (template != null && !usedFullTags.exists(template.fullTag))
		{
			usedFullTags.set(template.fullTag, 1);
			
			if (template.extend != null && template.extend != "")
			{
				detectUnusedTemplates_addToUsed(get(template.extend), usedFullTags);
			}
			
			for (forceComponent in template.forcedCompnents)
			{
				detectUnusedTemplates_addToUsed(get(forceComponent), usedFullTags);
			}
			
			for (tag in detectUnusedTemplates_getDocTags(template.doc))
			{
				detectUnusedTemplates_addToUsed(findTemplate(template.fullTag, tag), usedFullTags);
			}
		}
	}
	
	function detectUnusedTemplates_getDocTags(doc:HaqXmlNodeElement) : Array<String>
	{
		var r = [];
		for (node in doc.children)
		{
			if (node.name.startsWith("haq:"))
			{
				r.push(node.name.substr("haq:".length));
			}
			r = r.concat(detectUnusedTemplates_getDocTags(node));
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
		r += Lambda.map(templates.keysIterable(), function(fullTag) {
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
}
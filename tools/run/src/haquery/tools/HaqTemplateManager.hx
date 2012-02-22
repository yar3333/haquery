package haquery.tools;

import haquery.server.FileSystem;
import haquery.server.io.File;
import haquery.server.HaqDefines;

import haquery.tools.HaqTemplate;
import haquery.base.HaqTemplateParser.HaqTemplateNotFoundException;

import haquery.server.Lib;

using haquery.StringTools;
using haquery.HashTools;

class HaqTemplateManager extends haquery.base.HaqTemplateManager<HaqTemplate>
{
	var classPaths : Array<String>;
	
	public function new(classPaths:Array<String>)
	{
		super();
		
		this.classPaths = classPaths;
		
		fillTemplates(HaqDefines.folders.pages);
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
			Lib.println("run warning: package '" + pack + "' not found.");
		}
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
	
	public function getFullTags() : Array<String>
	{
		return Lambda.array(templates.keysIterable());
	}
}
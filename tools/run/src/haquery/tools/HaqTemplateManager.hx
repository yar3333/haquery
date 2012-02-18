package haquery.tools;

import haquery.server.FileSystem;
import haquery.tools.HaqTemplate;

using haquery.HashTools;

class HaqTemplateManager extends haquery.base.HaqTemplateManager<HaqTemplate>
{
	var classPaths : Array<String>;
	
	public function new(classPaths:Array<String>)
	{
		this.classPaths = classPaths;
		super();
	}
	
	override function parseTemplate(fullTag:String) : HaqTemplate
	{
		return new HaqTemplate(classPaths, fullTag);
	}
	
	override function getFullPath(path:String)
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
			var template = templates.get(fullTag);
			var importsParam = "[" + Lambda.map(template.imports, function(s) return "'" + s + "'").join(",") + "]";
			return "'" + fullTag + "' : new haquery.client.HaqTemplate(" + importsParam + ", '" + template.clientClassName + "')";
		}).join(",\n");
		r += "\n});\n";
		return r;
	}
}
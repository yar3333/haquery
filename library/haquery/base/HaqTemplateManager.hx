package haquery.base;
	
#if (php || neko)
typedef Page = haquery.server.HaqPage
#elseif js
typedef Page = haquery.client.HaqPage
#end

import  haquery.server.FileSystem;

using haquery.StringTools;

class HaqTemplateManager<Template:HaqTemplate>
{
	public var templates(default, null) : Hash<Template>;
	
	public function new()
	{
		templates = new Hash<Template>();
		fillTemplates(HaqDefines.folders.pages);
	}
	
	function fillTemplates(pack:String)
	{
		var path = getFullPath(pack.replace(".", "/"));
		for (file in FileSystem.readDirectory(path))
		{
			if (FileSystem.isDirectory(path + "/" + file))
			{
				var fullTag = pack + "." + file;
				var template = parseTemplate(fullTag);
				if (template != null)
				{
					templates.set(fullTag, template);
				}
				fillTemplates(fullTag);
			}
		}
	}
	
	function parseTemplate(fullTag:String) : Template
	{
		throw "This method must be overriten.";
		return null;
	}
	
	public function findTemplate(parentFullTag:String, tag:String) : Template
	{
		var packageName = getPackageByFullTag(parentFullTag);
		
		var template = templates.get(packageName + '.' + tag);
		if (template == null)
		{
			for (importPackage in templates.get(parentFullTag).imports)
			{
				template = templates.get(importPackage + '.' + tag);
				if (template != null)
				{
					break;
				}
			}
		}
		
		return template;
	}
	
	function getPackageByFullTag(fullTag:String)
	{
		var n = fullTag.lastIndexOf('.');
		if (n >= 0)
		{
			return fullTag.substr(0, n);
		}
		return '';
	}
	
	function getFullPath(path:String)
	{
		return path;
	}
}
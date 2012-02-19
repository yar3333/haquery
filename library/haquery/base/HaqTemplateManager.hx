package haquery.base;
	
import  haquery.server.FileSystem;

using haquery.StringTools;

class HaqTemplateManager<Template:HaqTemplate>
{
	public var templates(default, null) : Hash<Template>;
	
	public function new()
	{
		templates = new Hash<Template>();
		fillTemplates();
	}
	
	#if (php || neko)
	
	function fillTemplates()
	{
		throw "This method must be overriten.";
	}
	
	function fillTemplatesBySearch(pack:String)
	{
		var path = getFullPath(pack.replace(".", "/")) + '/';
		for (file in FileSystem.readDirectory(path))
		{
			if (file != HaqDefines.folders.support && FileSystem.isDirectory(path + file))
			{
				var fullTag = pack + "." + file;
				
				if (!templates.exists(fullTag) && isTemplateExists(fullTag))
				{
					var template = parseTemplate(fullTag);
					if (template != null)
					{
						templates.set(fullTag, template);
					}
					if ((pack.replace(".", "/") + "/").startsWith(HaqDefines.folders.pages + '/'))
					{
						fillTemplatesBySearch(fullTag);
					}
					
					for (importPack in template.imports)
					{
						fillTemplatesBySearch(importPack);
					}
				}
			}
		}
	}
	
	function isTemplateExists(fullTag:String)
	{
		var localPath = fullTag.replace(".", "/");
		var path = getFullPath(localPath);
		if (path != null && FileSystem.exists(path) && FileSystem.isDirectory(path))
		{
			if (
				getFullPath(localPath + '/template.html') != null
			 || getFullPath(localPath + '/Client.hx') != null
			 || getFullPath(localPath + '/Server.hx') != null
			) {
				return true;
			}
		}
		return false;
	}
	
	function parseTemplate(fullTag:String) : Template
	{
		throw "This method must be overriten.";
		return null;
	}
	
	#elseif js
	
	function fillTemplates()
	{
		throw "This method must be overriden.";
	}
	
	#end
	
	public function findTemplate(parentFullTag:String, tag:String) : Template
	{
		//trace("findTemplate " + parentFullTag + ", " + tag);
		
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
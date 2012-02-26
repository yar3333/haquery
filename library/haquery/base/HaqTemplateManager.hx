package haquery.base;
	
#if (php || neko)
import haquery.server.FileSystem;
import haquery.server.Lib;
#end

import haquery.base.HaqTemplateParser.HaqTemplateNotFoundException;

using haquery.StringTools;

class HaqTemplateManager<Template:HaqTemplate>
{
	var templates(default, null) : Hash<Template>;
	
	public function new()
	{
		templates = new Hash<Template>();
	}
	
	public function get(fullTag:String) : Template
	{
		#if (php || neko)
		if (templates.exists(fullTag))
		{
			var r = templates.get(fullTag);
			if (r == null)
			{
				r = newTemplate(fullTag);
				templates.set(fullTag, r);
			}
			return r;
		}
		return null;
		#elseif js
		return templates.get(fullTag);
		#end
	}
	
	#if (php || neko)
	function newTemplate(fullTag:String) : Template
	{
		return null; 
	}
	#end
	
	public function findTemplate(parentFullTag:String, tag:String) : Template
	{
		var template = get(getPackageByFullTag(parentFullTag) + '.' + tag);
		
		if (template == null)
		{
			for (importPackage in get(parentFullTag).imports)
			{
				template = get(importPackage + '.' + tag);
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
}
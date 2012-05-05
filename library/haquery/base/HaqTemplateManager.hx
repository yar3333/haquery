package haquery.base;
	
#if !client
import haquery.server.FileSystem;
import haquery.server.Lib;
#end

import haquery.base.HaqTemplateParser.HaqTemplateNotFoundException;

using haquery.StringTools;

class HaqTemplateManager<Template:HaqTemplate>
{
	var templates(default, null) : Hash<Template>;
	
	/**
	 * Vars to be (was) sended to the client.
	 */
	public var sharedStorage(default, null) : HaqSharedStorage;
	
	public function new()
	{
		templates = new Hash<Template>();
		sharedStorage = new HaqSharedStorage();
	}
	
	public function get(fullTag:String) : Template
	{
		#if !client
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
		#else
		return templates.get(fullTag);
		#end
	}
	
	#if !client
	function newTemplate(fullTag:String) : Template
	{
		return null; 
	}
	#end
	
	public function findTemplate(parentFullTag:String, tag:String) : Template
	{
		if (tag.indexOf(".") >= 0)
		{
			return get(tag);
		}
		
		var template : Template = null;
		
		if (!parentFullTag.startsWith(HaqDefines.folders.pages + "."))
		{
			template = get(getPackageByFullTag(parentFullTag) + '.' + tag);
		}
		
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
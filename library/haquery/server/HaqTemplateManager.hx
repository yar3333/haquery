package haquery.server;

#if server

import haquery.common.HaqComponentTools;
import haquery.common.HaqSharedStorage;
import haquery.Exception;
import haquery.server.HaqComponent;
import haquery.server.HaqTemplate;
import haquery.server.Lib;
import haxe.htmlparser.HtmlNodeElement;
import haquery.common.HaqTemplateExceptions;
import models.server.Page;
using haquery.StringTools;

class HaqTemplateManager
{
	static inline var MIN_DATE = new Date(2000, 0, 0, 0, 0, 0);
	
	/**
	 * Vars to be sended to the client.
	 */
	public var sharedStorage(default, null) : HaqSharedStorage;
	
	var registeredScripts : Array<String>;
	var registeredStyles : Array<String>;
	
	public function new()
	{
		sharedStorage = new HaqSharedStorage();
		
		registeredScripts = [ "haquery/client/jquery.js", "haquery/client/haquery.js" ];
		registeredStyles = [ "haquery/client/haquery.css" ];
	}
	
	public function get(fullTag:String) : HaqTemplate
	{
		return new HaqTemplate(fullTag);
	}
	
	public function createPage(pageFullTag:String, attr:Hash<Dynamic>) : Page
	{
        var template = get(pageFullTag);
		Lib.assert(template != null, "HAQUERY ERROR could't find page '" + pageFullTag + "'.");
		var component = newComponent(template, null, '', attr, null, false);
		
		var page : Page;
		try 
		{
			page = cast(component, Page);
		}
		catch (e:Dynamic)
		{
			throw new Exception("Class cast error: '" + template.serverClassName + "' must be extends from models.server.Page.");
		}
		
		return page;
	}
	
	public function createComponent(parent:HaqComponent, tag:String, id:String, attr:Hash<Dynamic>, parentNode:HtmlNodeElement, isCustomRender:Bool) : HaqComponent
	{
        try
		{
			return newComponent(get(tag), parent, id, attr, parentNode, isCustomRender);
		}
		catch (e:HaqTemplateNotFoundException)
		{
			throw new Exception("HAQUERY ERROR could't find component '" + tag + "' for parent '" + parent.fullTag + "'.");
			return null;
		}
	}
	
	function newComponent(template:HaqTemplate, parent:HaqComponent, id:String, attr:Hash<Dynamic>, parentNode:HtmlNodeElement, isCustomRender:Bool) : HaqComponent
	{
        Lib.profiler.begin('newComponent');
			Lib.assert(template != null, "Template for id = '" + id + "' not found.");
			
			var clas = Type.resolveClass(template.serverClassName);
			Lib.assert(clas != null, "Server class '" + template.serverClassName + "' for component '" + template.fullTag + "' not found.");
			
			var r : HaqComponent = null;
			try
			{
				r = cast(Type.createInstance(clas, []), HaqComponent);
			}
			catch (e:Dynamic)
			{
				Lib.assert(false, "Can't cast server class '" + template.serverClassName + "' to HaqComponent. Check class extends.");
			}
			
			r.construct(this, template.fullTag, parent, id, template.getDocCopy(), attr, parentNode, isCustomRender);
		Lib.profiler.end();
		return r;
	}
	
	function getFullUrl(fullTag:String, url:String) : String
	{
		if (url.startsWith("~/"))
		{
			url = url.substr(2);
		}
		
		if (fullTag != null && !url.startsWith("http://") && !url.startsWith("/") && !url.startsWith("<"))
		{
			var template = get(fullTag);
			Lib.assert(template != null, "Template '" + fullTag + "' not found.");
			url = template.getSupportFilePath(url);
		}
		
		return url;
	}
	
	/**
	 * Tells HaQuery to load JS file from support component folder.
	 * @param	fullTag Component package name.
	 * @param	url Url to js file (global or related to support component folder).
	 */
    public function registerScript(fullTag:String, url:String) : Void
	{
		url = getFullUrl(fullTag, url);
		if (!Lambda.has(registeredScripts, url))
		{
			registeredScripts.push(url);
		}
	}
	
	/**
	 * Tells HaQuery to load CSS file from support component folder.
	 * @param	fullTag Component package name.
	 * @param	url Url to css file (global or related to support component folder).
	 */
	public function registerStyle(fullTag:String, url:String) : Void
	{
		url = getFullUrl(fullTag, url);
		if (!Lambda.has(registeredStyles, url))
		{
			registeredStyles.push(url);
		}
	}
	
	public function getRegisteredStyles() : Array<String>
	{
		return registeredStyles;
	}
	
	public function getRegisteredScripts() : Array<String>
	{
		return registeredScripts;
	}
	
	public function createDocComponents(parent:HaqComponent, baseNode:HtmlNodeElement, isCustomRender:Bool) : Array<HaqComponent>
    {
		var r = [];
		
		for (node in baseNode.children)
        {
			Lib.assert(node.name != 'haq:placeholder');
			Lib.assert(node.name != 'haq:content');
            
            if (node.name.startsWith('haq:'))
            {
				r.push(createComponent(parent, HaqComponentTools.htmlTagToFullTag(node.name.substr('haq:'.length)), node.getAttribute('id'), node.getAttributesAssoc(), node, isCustomRender));
            }
			else
			{
				r = r.concat(createDocComponents(parent, node, isCustomRender));
			}
        }
		
		return r;
    }
}

#end
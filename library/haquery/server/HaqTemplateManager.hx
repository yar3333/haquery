package haquery.server;

#if server

import haquery.common.HaqComponentTools;
import haquery.common.HaqStorage;
import stdlib.Exception;
import stdlib.Std;
import haquery.server.HaqComponent;
import haquery.server.HaqTemplate;
import haquery.server.Lib;
import haxe.htmlparser.HtmlNodeElement;
import haquery.common.HaqTemplateExceptions;
import models.server.Page;
using stdlib.StringTools;

class HaqTemplateManager
{
	public function new() {}
	
	public function get(fullTag:String) : HaqTemplate
	{
		return new HaqTemplate(fullTag);
	}
	
	public function createPage(pageFullTag:String, attr:Hash<Dynamic>) : Page
	{
        var template = get(pageFullTag);
		Std.assert(template != null, "HAQUERY ERROR could't find page '" + pageFullTag + "'.");
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
			Std.assert(template != null, "Template for id = '" + id + "' not found.");
			
			var clas = Type.resolveClass(template.serverClassName);
			Std.assert(clas != null, "Server class '" + template.serverClassName + "' for component '" + template.fullTag + "' not found.");
			
			var component : HaqComponent = null;
			try
			{
				component = cast(Type.createInstance(clas, []), HaqComponent);
			}
			catch (e:Dynamic)
			{
				Std.assert(false, "Can't cast server class '" + template.serverClassName + "' to HaqComponent. Check class extends.");
			}
			
			component.construct(template.fullTag, parent, id, template.getDocCopy(), attr, parentNode, isCustomRender);
		Lib.profiler.end();
		return component;
	}
	
	public function createDocComponents(parent:HaqComponent, baseNode:HtmlNodeElement, isCustomRender:Bool) : Array<HaqComponent>
    {
		var r = [];
		
		for (node in baseNode.children)
        {
			Std.assert(node.name != 'haq:placeholder');
			Std.assert(node.name != 'haq:content');
            
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
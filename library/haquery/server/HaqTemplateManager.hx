package haquery.server;

#if server

import haquery.common.HaqComponentTools;
import haquery.common.HaqStorage;
import stdlib.Exception;
import stdlib.Std;
import stdlib.Debug;
import haquery.server.HaqComponent;
import haquery.server.HaqTemplate;
import haquery.server.Lib;
import haxe.htmlparser.HtmlNodeElement;
import haquery.common.HaqTemplateExceptions;
import haquery.common.Generated;
using stdlib.StringTools;

class HaqTemplateManager
{
	public function new() {}
	
	public function get(fullTag:String) : HaqTemplate
	{
		return new HaqTemplate(fullTag);
	}
	
	public function createPage(pageFullTag:String, attr:Dynamic) : HaqPage
	{
        var template = get(pageFullTag);
		Debug.assert(template != null, "HAQUERY ERROR could't find page '" + pageFullTag + "'.");
		var component = newComponent(template, null, "", attr, null, false);
		
		var page : HaqPage;
		try 
		{
			page = cast(component, HaqPage);
		}
		catch (e:Dynamic)
		{
			throw new Exception("Class cast error: '" + template.serverClassName + "' must be extends from haquery.server.HaqPage.");
		}
		
		return page;
	}
	
	public function createComponent(parent:HaqComponent, tag:String, id:String, attr:Dynamic, parentNode:HtmlNodeElement, isCustomRender:Bool) : HaqComponent
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
	
	function newComponent(template:HaqTemplate, parent:HaqComponent, id:String, attr:Dynamic, parentNode:HtmlNodeElement, isCustomRender:Bool) : HaqComponent
	{
		Debug.assert(attr == null || !Std.is(attr, haxe.ds.StringMap));
		
		if (parent != null && parent.page.config.logSystemCalls) trace("HAQUERY newComponent [" + parent.prefixID + id + "/" + template.fullTag + "]");
		
		Debug.assert(template != null, "Template for id = '" + id + "' not found.");
		
		var clas = Type.resolveClass(template.serverClassName);
		Debug.assert(clas != null, "Server class '" + template.serverClassName + "' for component '" + template.fullTag + "' not found.");
		
		var component : HaqComponent = null;
		try
		{
			component = cast(Type.createInstance(clas, []), HaqComponent);
		}
		catch (e:Dynamic)
		{
			Debug.assert(false, "Can't cast server class '" + template.serverClassName + "' to HaqComponent. Check class extends.");
		}
		
		component.construct(template.fullTag, parent, id, template.getDocCopy(), attr, parentNode, isCustomRender);
		
		return component;
	}
	
	public function createDocComponents(parent:HaqComponent, baseNode:HtmlNodeElement, isCustomRender:Bool) : Array<HaqComponent>
	{
		Lib.profiler.begin("createDocComponents");
		var r =  createDocComponentsInner(parent, baseNode, isCustomRender);
		Lib.profiler.end();
		return r;
	}
	function createDocComponentsInner(parent:HaqComponent, baseNode:HtmlNodeElement, isCustomRender:Bool) : Array<HaqComponent>
    {
		var r = [];
		
		for (node in baseNode.children)
        {
			Debug.assert(node.name != 'haq:placeholder');
			Debug.assert(node.name != 'haq:content');
            
            if (node.name.startsWith('haq:'))
            {
				r.push(createComponent(parent, HaqComponentTools.htmlTagToFullTag(node.name.substr('haq:'.length)), node.getAttribute('id'), node.getAttributesObject(), node, isCustomRender));
            }
			else
			{
				r = r.concat(createDocComponentsInner(parent, node, isCustomRender));
			}
        }
		
		return r;
    }
}

#end
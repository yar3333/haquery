package components.haquery.dynamiclistitem;

import js.JQuery;
import haquery.HashTools;
import haquery.client.HaqComponent;
import haxe.htmlparser.HtmlDocument;
import haxe.htmlparser.HtmlNodeElement;

using haquery.StringTools;

private typedef ComponentData =
{
	var fullTag : String;
	var prefixID : String;
	var id : String;
	var params : Hash<String>;
	var chilren : Array<ComponentData>;
}

class Client extends components.haquery.listitem.Client
{
	var nextChildID : Int;
	
	function new()
	{
		super();
		nextChildID = 1;
	}
	
	function factoryInit(parentElem:JQuery, docs:Hash<String>, params:Dynamic)
	{
		var html = docs.get("");
		html = components.haquery.listitem.Tools.apply(html, HashTools.hashify(params));
		
		var doc = new HtmlDocument(html);
		prepareDoc(parent.parent.fullTag, prefixID, doc);
		
		var components = parentElem.append(doc.innerHTML);
		HaqElemEventManager.elemsWasChanged();
		
		
	}
	
	function prepareDoc(fullTag:String, prefixID:String, node:HtmlNodeElement) : Array<ComponentData>
	{
		var r = new Array<ComponentData>();
		
		if (!node.name.startWith("haq:") && node.hasAttribute("id"))
		{
			var id = node.getAttribute("id");
			if (id != "")
			{
				node.attr("id", prefixID + id);
			}
		}
			
		for (child in node.children())
		{
			if (!child.name.startWith("haq:"))
			{
				prepareDoc(fullTag, prefixID, child);
			}
			else
			{
				var id = getComponentID(child);
				var t = manager.findTemplate(fullTag, child.name.substr("haq:".length));
				var html = docs.get(t.fullTag);
				var doc = new HtmlDocument(html);
				r.push({ fullTag:t.fullTag, prefixID:prefixID, id:id, params:child.getAttributes(), chilren:prepareDoc(t.fullTag, prefixID + id, doc) });
				child.replace(doc);
			}
		}
		
		return r;
	}
	
	function createChildComponents(parent:HaqComponent, components:Array<ComponentData>)
	{
		for (c in components)
		{
			var pc = manager.createComponent(parent, c.fullTag, c.id, c.params);
			createChildComponents(pc, c.chilren);
		}
	}

	function getComponentID(node:HtmlNodeElement) : String
	{
		var id = "";
		if (node.hasAttribute("id"))
		{
			id = node.getAttribute("id");
		}
		if (id == "")
		{
			id = "c" + nextChildID;
			nextChildID++;
		}
		return id;
	}
}
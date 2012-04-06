package components.haquery.dynamiclistitem;

import js.JQuery;
import haquery.HashTools;
import haquery.client.HaqComponent;
import haxe.htmlparser.HtmlDocument;
import haxe.htmlparser.HtmlNodeElement;
import haquery.client.HaqElemEventManager;

using haquery.StringTools;
using haquery.HashTools;

typedef Tools = components.haquery.listitem.Tools;

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
	
	var docs : Hash<String>;
	
	function new()
	{
		super();
		nextChildID = 1;
	}
	
	function factoryInit(parentElem:JQuery, docs:Hash<String>, params:Dynamic)
	{
		this.docs = docs;
		
		//trace("docs.keys = " + Lambda.array(docs.keysIterable()).join(", "));
		
		var html = docs.get("");
		
		var doc = Tools.applyHtmlParams(html, cast HashTools.hashify(params));
		var childComponents = prepareDoc(parent.parent.fullTag, prefixID, doc);
		
		parentElem.append(doc.innerHTML);
		HaqElemEventManager.elemsWasChanged();
		
		dynamicCreateChildComponents(this, childComponents);
	}
	
	function prepareDoc(fullTag:String, prefixID:String, node:HtmlNodeElement) : Array<ComponentData>
	{
		var r = new Array<ComponentData>();
		
		if (!node.name.startsWith("haq:") && node.hasAttribute("id"))
		{
			var id = node.getAttribute("id");
			if (id != "")
			{
				node.setAttribute("id", prefixID + id);
			}
		}
			
		for (child in node.children)
		{
			if (!child.name.startsWith("haq:"))
			{
				r = r.concat(prepareDoc(fullTag, prefixID, child));
			}
			else
			{
				var id = getComponentID(child);
				var tag = child.name.substr("haq:".length);
				var t = manager.findTemplate(fullTag, tag);
				if (t == null)
				{
					throw "Component template '" + tag + "' not found for parent component '" + fullTag + "'.";
				}
				var html = docs.get(t.fullTag);
				var doc = new HtmlDocument(html);
				r.push({ fullTag:t.fullTag, prefixID:prefixID, id:id, params:child.getAttributesAssoc(), chilren:prepareDoc(t.fullTag, prefixID + id, doc) });
				child.parent.replaceChildWithInner(child, doc);
			}
		}
		
		return r;
	}
	
	function dynamicCreateChildComponents(parent:HaqComponent, components:Array<ComponentData>)
	{
		for (c in components)
		{
			var pc = manager.createComponent(parent, c.fullTag, c.id, [ c.params ]);
			dynamicCreateChildComponents(pc, c.chilren);
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
package components.haquery.dynamicfactoryitem;

import js.JQuery;
import haxe.htmlparser.HtmlDocument;
import haxe.htmlparser.HtmlNodeElement;
import haquery.common.HaqDefines;
import haquery.client.HaqInternals;
import haquery.client.HaqTemplateManager;
import haquery.client.HaqComponent;
import haquery.client.HaqElemEventManager;
import haquery.HashTools;

using haquery.StringTools;
using haquery.HashTools;

typedef Tools = components.haquery.factoryitem.Tools;

private typedef ComponentData =
{
	var fullTag : String;
	var prefixID : String;
	var id : String;
	var chilren : Array<ComponentData>;
}

class Client extends components.haquery.factoryitem.Client
{
	var componentAnonimIDs : Hash<Int>;
	var childComponents : Array<ComponentData>;
	
	function new()
	{
		super();
		componentAnonimIDs = new Hash<Int>();
	}
	
	override function construct(manager:HaqTemplateManager, fullTag:String, parent:HaqComponent, id:String, isDynamic:Bool, dynamicParams:Dynamic)
	{
		var parentElem:JQuery = dynamicParams.parentElem;
		var html:String = dynamicParams.html;
		var params:Dynamic = dynamicParams.params;
		
		var doc = Tools.applyHtmlParams(html, cast HashTools.hashify(params));
		childComponents = prepareDoc(manager, parent.parent.fullTag, parent.prefixID + id + HaqDefines.DELIMITER, doc);
		parentElem.append(doc.innerHTML);
		HaqElemEventManager.elemsWasChanged();
		
		super.construct(manager, fullTag, parent, id, isDynamic, dynamicParams);
	}
	
	function prepareDoc(manager:HaqTemplateManager, fullTag:String, prefixID:String, node:HtmlNodeElement) : Array<ComponentData>
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
				r = r.concat(prepareDoc(manager, fullTag, prefixID, child));
			}
			else
			{
				var id = getComponentID(prefixID, child);
				var tag = child.name.substr("haq:".length);
				var t = manager.findTemplate(fullTag, tag);
				if (t == null)
				{
					throw "Component template '" + tag + "' not found for parent component '" + fullTag + "'.";
				}
				var doc = new components.haquery.dynamicfactory.DocStorage(manager).get(t.fullTag);
				r.push( { 
					 fullTag: t.fullTag
					,prefixID: prefixID
					,id: id
					,chilren: prepareDoc(manager, t.fullTag, prefixID + id + HaqDefines.DELIMITER, doc)
				} );
				HaqInternals.addComponent(t.fullTag, prefixID + id);
				child.parent.replaceChildWithInner(child, doc);
			}
		}
		
		return r;
	}
	
	function hashToObject(h:Hash<Dynamic>) : Dynamic
	{
		var r = { };
		for (k in h.keys())
		{
			Reflect.setField(r, k, h.get(k));
		}
		return r;
	}
	
	function getComponentID(prefixID:String,node:HtmlNodeElement) : String
	{
		var id = "";
		if (node.hasAttribute("id"))
		{
			id = node.getAttribute("id");
		}
		if (id == "")
		{
			if (!componentAnonimIDs.exists(prefixID))
			{
				componentAnonimIDs.set(prefixID, 1);
			}
			var n = componentAnonimIDs.get(prefixID);
			id = "haqc_" + n;
			componentAnonimIDs.set(prefixID, n + 1);
		}
		return id;
	}
	
	override function createChildComponents()
	{
		for (c in childComponents)
		{
			manager.createComponent(this, c.fullTag, c.id, true);
		}
	}
}
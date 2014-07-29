package components.haquery.factoryitem;

import haquery.client.Lib;
import haquery.common.HaqComponentTools;
import haquery.common.HaqStorage;
import htmlparser.HtmlDocument;
import haxe.Unserializer;
import stdlib.Exception;
import js.JQuery;
import htmlparser.HtmlNodeElement;
import haquery.common.HaqDefines;
import haquery.client.HaqInternals;
import haquery.client.HaqComponent;
import stdlib.Std;
using stdlib.StringTools;

typedef Tools = components.haquery.listitem.Tools;
typedef Factory = components.haquery.factory.Client;

private typedef ComponentData =
{
	var fullTag : String;
	var prefixID : String;
	var id : String;
	var chilren : Array<ComponentData>;
}

class Client extends BaseClient
{
	var componentAnonimIDs : Map<String,Int>;
	var childComponents : Array<ComponentData>;
	
	function new()
	{
		super();
		componentAnonimIDs = new Map<String,Int>();
	}
	
	override function construct(fullTag:String, parent:HaqComponent, id:String, isDynamic:Bool, dynamicParams:Dynamic)
	{
		var parentElem:JQuery = dynamicParams.parentElem;
		var html:String = dynamicParams.html;
		var params:Dynamic = dynamicParams.params;
		var append:Bool = dynamicParams.append;
		
		var doc = new HtmlDocument(Tools.applyHtmlParams(html, params));
		childComponents = prepareDoc(parent.page.storage, parent.parent.fullTag, parent.prefixID + id + HaqDefines.DELIMITER, doc);
		if (append)
		{
			parentElem.append(doc.innerHTML);
		}
		else
		{
			parentElem.prepend(doc.innerHTML);
		}
		
		super.construct(fullTag, parent, id, isDynamic, dynamicParams);
	}
	
	function prepareDoc(storage:HaqStorage, fullTag:String, prefixID:String, node:HtmlNodeElement) : Array<ComponentData>
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
				r = r.concat(prepareDoc(storage, fullTag, prefixID, child));
			}
			else
			{
				var id = getComponentID(prefixID, child);
				var tag = HaqComponentTools.htmlTagToFullTag(child.name.substr("haq:".length));
				
				storage.setInstanceVar(prefixID + id, "html", child.innerHTML, HaqStorage.DESTINATION_CLIENT);
				
				var t = Lib.manager.get(tag);
				if (t == null)
				{
					throw new Exception("Component template '" + tag + "' not found for parent component '" + fullTag + "'.");
				}
				
				var doc = storage.existsStaticVar(Factory, t.fullTag)
					? Unserializer.run(storage.getStaticVar(Factory, t.fullTag))
					: child;
				
				r.push( { 
					 fullTag: t.fullTag
					,prefixID: prefixID
					,id: id
					,chilren: prepareDoc(storage, t.fullTag, prefixID + id + HaqDefines.DELIMITER, doc)
				} );
				HaqInternals.addComponent(t.fullTag, prefixID + id);
				child.parent.replaceChildWithInner(child, doc);
			}
		}
		
		return r;
	}
	
	function hashToObject(h:Map<String,Dynamic>) : Dynamic
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
			var component = Lib.manager.createComponent(this, c.fullTag, c.id, true);
			component.callMethodForEach("preInit", true);
			component.callMethodForEach("init", false);
		}
	}
	
	public function remove()
	{
		parent.components.remove(id);
	}
}
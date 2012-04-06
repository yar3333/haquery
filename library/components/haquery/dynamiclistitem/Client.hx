package components.haquery.dynamiclistitem;

import js.JQuery;
import haxe.htmlparser.HtmlDocument;
import haxe.htmlparser.HtmlNodeElement;
import haquery.client.HaqDefines;
import haquery.client.HaqInternals;
import haquery.client.HaqTemplateManager;
import haquery.client.HaqComponent;
import haquery.client.HaqElemEventManager;
import haquery.HashTools;

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
	var componentAnonimIDs : Hash<Int>;
	var docs : Hash<String>;
	var childComponents : Array<ComponentData>;
	
	function new()
	{
		super();
		componentAnonimIDs = new Hash<Int>();
	}
	
	override function construct(manager:HaqTemplateManager, fullTag:String, parent:HaqComponent, id:String, factoryInitParams:Array<Dynamic> = null)
	{
		var parentElem:JQuery = factoryInitParams[0];
		var docs:Hash<String> = factoryInitParams[1];
		var params:Dynamic = factoryInitParams[2];
		
		this.docs = docs;
		
		trace("docs.keys = " + Lambda.array(docs.keysIterable()).join(", "));
		
		var html = docs.get("");
		
		var doc = Tools.applyHtmlParams(html, cast HashTools.hashify(params));
		childComponents = prepareDoc(manager, parent.parent.fullTag, parent.prefixID + id + HaqDefines.DELIMITER, doc);
		parentElem.append(doc.innerHTML);
		HaqElemEventManager.elemsWasChanged();
		
		super.construct(manager, fullTag, parent, id, factoryInitParams);
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
				var html = docs.get(t.fullTag);
				var doc = new HtmlDocument(html);
				r.push( { 
					 fullTag: t.fullTag
					,prefixID: prefixID
					,id: id
					,params: child.getAttributesAssoc()
					,chilren: prepareDoc(manager, t.fullTag, prefixID + id + HaqDefines.DELIMITER, doc)
				} );
				HaqInternals.addComponent(t.fullTag, prefixID + id);
				child.parent.replaceChildWithInner(child, doc);
			}
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
			manager.createComponent(this, c.fullTag, c.id, [ c.params ]);
		}
	}
}
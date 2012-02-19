package haquery.components.factory;

import haquery.client.HaqDefines;
import haquery.client.HaqElemEventManager;
import haxe.Unserializer;
import js.JQuery;
import js.Dom;

class Client extends Base
{
    var component : String;
	var template : String;
	
	function init()
    {
        component = q('#component').val(); q('#component').remove();
        template = Unserializer.run(q('#template').val()); q('#template').remove();
    }
	
	public function create(parentElem:JQuery, factoryInitParams:Array<Dynamic>)
	{
		if (factoryInitParams == null) factoryInitParams = [];
		
		var doc = new JQuery(template);
		var nodes : Array<HtmlDom> = cast doc;
		for (node in nodes)
		{
			prepareDoc(node, "c" + Std.string(length));
		}
		doc.appendTo(parentElem);
		
		HaqElemEventManager.elemsWasChanged();
		
		var c = manager.createComponent(this, component, "c" + Std.string(length), factoryInitParams);
		
		length++;
	}
	
	function prepareDoc(node:HtmlDom, childID:String)
	{
		if (node.id != "")
		{
			node.id = prefixID + childID + HaqDefines.DELIMITER + node.id;
		}
		
		var nodes : Array<HtmlDom> = cast node.childNodes;
		for (child in nodes)
		{
			prepareDoc(child, childID);
		}
	}
}
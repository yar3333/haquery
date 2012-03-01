package components.haquery.factory;

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
		for (node in doc)
		{
			prepareDoc(node, "c" + Std.string(length));
		}
		doc.appendTo(parentElem);
		
		HaqElemEventManager.elemsWasChanged();
		
		var c = manager.createComponent(this, component, "c" + Std.string(length), factoryInitParams);
		
		length++;
	}
	
	function prepareDoc(node:JQuery, childID:String)
	{
		var id = node.attr("id");
		
		if (id != "")
		{
			node.attr("id", prefixID + childID + HaqDefines.DELIMITER + id);
		}
		
		for (child in node.children())
		{
			prepareDoc(child, childID);
		}
	}
}
package components.haquery.factory;

import haquery.client.Lib;
import haquery.client.HaqComponent;
import haxe.Unserializer; 
import js.JQuery;

class Client extends BaseClient
{
	var html : String;
	
	function init()
    {
        html = page.storage.getInstanceVar(this, "html");
		page.storage.removeInstanceVar(this, "html");
    }
	
	public function create(parentElem:JQuery, params:Dynamic) : HaqComponent
	{
		var n = length;
		var r = Lib.manager.createComponent(this, "components.haquery.factoryitem", Std.string(n), true, { parentElem:parentElem, html:html, params:params } );
		q("#length").val(n + 1);
		return r;
	}
}
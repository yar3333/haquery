package components.haquery.dynamicfactory;

import haquery.client.HaqComponent;
import haquery.client.HaqEvent;
import haxe.htmlparser.HtmlNodeElement;
import haxe.Unserializer; 
import js.JQuery;

class Client extends components.haquery.factory.Client
{
	var html : String;
	
	function init()
    {
        html = Unserializer.run(q("#html").val()); q("#html").remove();
    }
	
	public function create(parentElem:JQuery, params:Dynamic) : HaqComponent
	{
		var n = length;
		var r = manager.createComponent(this, "components.haquery.dynamicfactoryitem", Std.string(n), true, { parentElem:parentElem, html:html, params:params } );
		q('#length').val(n + 1);
		return r;
	}
}
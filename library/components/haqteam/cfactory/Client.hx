package components.haqteam.cfactory;

import haquery.client.HaqComponent;
import haquery.common.HaqEvent;
import haxe.htmlparser.HtmlNodeElement;
import haxe.Unserializer; 
import js.JQuery;

class Client extends BaseClient
{
	var html : String;
	
	function init()
    {
        html = Unserializer.run(q("#html").val()); q("#html").remove();
    }
	
	public function create(parentElem:JQuery, params:Dynamic) : HaqComponent
	{
		var n = length;
		var r = manager.createComponent(this, "components.haqteam.cfactoryitem", Std.string(n), true, { parentElem:parentElem, html:html, params:params } );
		q('#length').val(n + 1);
		return r;
	}
}
package components.haquery.dynamicfactory;

import haxe.htmlparser.HtmlNodeElement;
import haxe.Unserializer; 
import js.JQuery;

class Client extends components.haquery.factory.Client
{
	var html : HtmlNodeElement;
	
	function init()
    {
        html = Unserializer.run(q("#html").val()); q("#html").remove();
    }
	
	public function create(parentElem:JQuery, params:Dynamic)
	{
		var n = length;
		manager.createComponent(this, "components.haquery.dynamicfactoryitem", Std.string(n), true, { parentElem:parentElem, html:html, params:params });
		q('#length').val(n + 1);
	}
}
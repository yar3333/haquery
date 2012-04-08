package components.haquery.dynamicfactory;

import haxe.Unserializer; 
import js.JQuery;

class Client extends components.haquery.factory.Client
{
	var docs : Hash<String>;
	
	function init()
    {
        docs = Unserializer.run(q("#docs").val()); q("#docs").remove();
    }
	
	public function create(parentElem:JQuery, params:Dynamic)
	{
		var n = length;
		manager.createComponent(this, "components.haquery.dynamicfactoryitem", Std.string(n), true, { parentElem:parentElem, docs:docs, params:params });
		q('#length').val(n + 1);
	}
}
package components.haquery.dynamiclist;

import haxe.Unserializer; 
import js.JQuery;

class Client extends components.haquery.list.Client
{
	var docs : Hash<String>;
	
	function init()
    {
        docs = Unserializer.run(q("#docs").val()); q("#docs").remove();
    }
	
	public function create(parentElem:JQuery, params:Dynamic)
	{
		manager.createComponent(this, "components.haquery.dynamiclistitem", Std.string(length), [ parentElem, docs, params ]);
		q('#length').val(length + 1);
	}
}
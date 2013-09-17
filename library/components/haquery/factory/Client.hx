package components.haquery.factory;

import haquery.client.Lib;
import haquery.client.HaqComponent;
import js.JQuery;

class Client extends BaseClient
{
	public function create(parentElem:JQuery, params:Dynamic, append=true) : HaqComponent
	{
		var n = length;
		var r = Lib.manager.createComponent(this, "components.haquery.factoryitem", Std.string(n), true, { parentElem:parentElem, html:page.storage.getInstanceVar(fullID, "html"), params:params, append:append } );
		page.storage.setInstanceVar(fullID, "length", n + 1);
		return r;
	}
	
	public function clear()
	{
		while (components.iterator().hasNext())
		{
			components.remove(components.iterator().next().id);
		}
	}
}
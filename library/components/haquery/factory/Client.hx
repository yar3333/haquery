package components.haquery.factory;

import haquery.client.Lib;
import haquery.client.HaqComponent;
import js.JQuery;

class Client extends BaseClient
{
	public function create(parentElem:JQuery, params:Dynamic) : HaqComponent
	{
		var n = length;
		var r = Lib.manager.createComponent(this, "components.haquery.factoryitem", Std.string(n), true, { parentElem:parentElem, html:page.storage.getInstanceVar(this, "html"), params:params } );
		page.storage.setInstanceVar(this, "length", n + 1);
		return r;
	}
}
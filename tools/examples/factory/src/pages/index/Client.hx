package pages.index;

import haquery.client.HaqComponent;
import haquery.client.HaqPage;

class Client extends HaqPage
{
    function init()
	{
		var factory : haquery.components.factory.Client = cast components.get("factory");
		factory.create(q('#container'), null);
	}
	
	function factory_click(t:HaqComponent)
	{
        trace("click on the client (" + t.id + ")");
	}
}
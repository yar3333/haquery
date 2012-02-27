package pages.index;

import haquery.client.HaqComponent;
import haquery.client.HaqPage;

class Client extends HaqPage
{
    var template : TemplateClient;
	
	function init()
	{
		template.factory.create(q('#container'), null);
	}
	
	function factory_click(t:HaqComponent)
	{
        trace("click on the client (" + t.id + ")");
	}
}
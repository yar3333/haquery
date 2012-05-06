package components.dynamiclists.item;

import haquery.client.Lib;
import haquery.client.HaqComponent;

class Client extends HaqComponent
{
    var template : TemplateClient;

    function init()
	{
		trace("client item.fullID = " + fullID);
	}
	
	function test_click(t, e)
    {
        trace("test_click on client " + fullID);
    }
}
package components.dynamiclists.item;

import haquery.server.Lib;
import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    var template : TemplateServer;
    
    function init()
	{
		trace("server item.fullID = " + fullID);
	}
    
	function test_click()
    {
        trace("test_click on server " + fullID);
    }
}
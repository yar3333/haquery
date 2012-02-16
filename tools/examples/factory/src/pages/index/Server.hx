package pages.index;

import haquery.server.HaqComponent;
import haquery.server.HaqPage;

class Server extends HaqPage
{
	function factory_click(t:HaqComponent)
	{
        trace("click on the server (" + t.id + ")");
	}
}
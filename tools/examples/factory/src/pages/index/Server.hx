package pages.index;

import haquery.server.HaqPage;

class Server extends HaqPage
{
    public function factory_click(t:HaqComponent)
	{
        trace("click on the server (" + t.id + ")");
	}
}
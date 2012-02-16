package pages.index;

import haquery.client.HaqPage;

class Client extends HaqPage
{
	public function factory_click(t:HaqComponent)
	{
        trace("click on the client (" + t.id + ")");
	}
}
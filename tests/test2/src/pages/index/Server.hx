package pages.index;

import haquery.server.HaqPage;

class Server extends HaqPage
{
	public function mybt1_click()
	{
		q('#status').html("mybt1 server pressed!");
	}
	
    public function mybt2_click()
	{
		q('#status').html("mybt2 server pressed!");
	}
}
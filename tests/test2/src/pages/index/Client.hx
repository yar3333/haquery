package pages.index;

import haquery.client.HaqPage;

class Client extends HaqPage
{
	public function mybt1_click()
	{
		q('#status').html("mybt1 client pressed!");
		return true;
	}
    
	public function mybt2_click()
	{
		q('#status').html("mybt2 client pressed!");
		return true;
	}
}
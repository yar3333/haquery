package pages.index;

import haquery.server.HaqPage;

class Server extends HaqPage
{
    public function simpleButton_click()
	{
		q('#status').html("simpleButton pressed on server");
	}
	
    public function componentButton_click()
	{
		q('#status').html("componentButton pressed on server");
	}
}
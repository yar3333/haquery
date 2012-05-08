package pages.index;

import haquery.server.HaqPage;

class Server extends HaqPage
{
    function simpleButton_click()
	{
		q('#status').html("simpleButton pressed on server");
	}
	
    function componentButton_click()
	{
		q('#status').html("componentButton pressed on server");
	}
}
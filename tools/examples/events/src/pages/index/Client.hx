package pages.index;

import haquery.client.HaqPage;

class Client extends HaqPage
{
	function simpleButton_click()
	{
		q('#status').html("simpleButton pressed on client");
	}
    
	function componentButton_click()
	{
		q('#status').html("componentButton pressed on client");
		//return false; // false to disable server handler call
	}
}
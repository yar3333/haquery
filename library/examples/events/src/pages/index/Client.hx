package pages.index;

import haquery.client.HaqPage;

class Client extends HaqPage
{
	public function simpleButton_click()
	{
		q('#status').html("simpleButton pressed on client");
	}
    
	public function componentButton_click()
	{
		q('#status').html("componentButton pressed on client");
		//return false; // false to disable server handler call
	}
}
package pages.test;

import js.Lib;
import haquery.client.HaqPage;

class Client extends HaqPage
{
	public function mylist_mybtA_click()
	{
		Lib.alert('client mylist_mybtA_click');
	}
	
	public function mybt_click()
	{
		trace('client mybt_click()');
	}
	
	public function calledFromServer()
	{
		trace('calledFromServer');
	}
}

package pages.test;

import php.Lib;
import haquery.server.HaqPage;
import haquery.server.HaQuery;

class Server extends HaqPage
{
	public function init() : Void
	{
		if (!HaQuery.isPostback)
		{
			var elem0 = new Hash<Hash<String>>();
			elem0.set('mybtA', new Hash<String>()); elem0.get('mybtA').set('text', 'A-0');
			elem0.set('mybtB', new Hash<String>()); elem0.get('mybtB').set('text', 'B-0');
			
			var elem1 = new Hash<Hash<String>>();
			elem1.set('mybtA', new Hash<String>()); elem1.get('mybtA').set('text', 'A-1');
			elem1.set('mybtB', new Hash<String>()); elem1.get('mybtB').set('text', 'B-1');
			
			var mylist : components.list.Server = cast(components.get('mylist'), components.list.Server);
			mylist.bind([ elem0, elem1 ]);
		}
	}
	
	public function mybt_click()
	{
		trace('server mybt_click()');
		callJsMethod('calledFromServer()');
	}
	
	public function mylist_mybtA_click()
	{
		trace('server mylist_mybtA_click');
	}
	
	public function mylist_mybtB_click()
	{
		trace('server mylist_mybtB_click');
	}
}
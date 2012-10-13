package pages.index;

import haquery.client.Lib;
import haquery.client.HaqPage;

class Client extends HaqPage
{
	function init()
	{
		template().pageKey.html(pageKey);
	}
	
	function simpleButton_click(t, e)
	{
		q('#status').html("simpleButton pressed on client");
	}
    
	function componentButton_click(t, e)
	{
		q('#status').html("componentButton pressed on client");
		//return false; // false to disable server handler call
	}
	
	function callSharedServerMethodA_click(t, e)
	{
		server().serverMethodA(1, "abc", function(e)
		{
			Lib.alert("callback after methodA calling = " + e);
		});
	}
	
	function callSharedServerMethodB_click(t, e)
	{
		server().serverMethodB(template().anotherPageKey.val(), function(e)
		{
			Lib.alert("callback after methodB calling = " + e);
		});
	}
	
	@shared function clientMethodA(a:Int, b:String) : Void
	{
		Lib.alert("Method clientMethodA called from server, a = " + a + ", b = " + b + ".");
	}
}
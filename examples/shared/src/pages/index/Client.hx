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
	
	function callSharedServerMethodD_click(t, e)
	{
		server().serverMethodD(template().anotherPageKey.val(), function(e)
		{
			Lib.alert("callback after shared server method D calling = " + e);
		});
	}
	
	function callAnotherServerMethodE_click(t, e)
	{
		server(template().anotherPageKey.val()).serverMethodE(this.pageKey, function(e)
		{
			Lib.alert("callback after another server method E calling = " + e);
		});
	}
	
	function callAnotherClientMethodF_click(t, e)
	{
		client(template().anotherPageKey.val()).clientMethodE(this.pageKey);
	}
	
	@shared function clientMethodA(a:Int, b:String) : Void
	{
		Lib.alert("Method clientMethodA called from server, a = " + a + ", b = " + b + ".");
	}
	
	@another function clientMethodD(a:Int, b:String) : Void
	{
		Lib.alert("Method clientMethodD called from another server, a = " + a + ", b = " + b + ".");
	}
	
	@another function clientMethodE(fromPageKey:String) : Void
	{
		Lib.alert("Method clientMethodE called from another client [" + fromPageKey + "].");
	}
}
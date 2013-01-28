package pages.index;

import haquery.client.Lib;

class Client extends BaseClient
{
	function init()
	{
		template().pageKey.html(pageKey);
	}
	
	function callSharedServerMethodB_click(t, e)
	{
		server().serverMethodB(template().anotherPageKey.val(), function(e)
		{
			Lib.alert("callback after methodB calling = " + e);
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
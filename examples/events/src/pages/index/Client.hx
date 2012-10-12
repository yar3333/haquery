package pages.index;

import haquery.client.Lib;
import haquery.client.HaqPage;

@:keep class Client extends HaqPage
{
	function simpleButton_click(t, e)
	{
		q('#status').html("simpleButton pressed on client");
	}
    
	function componentButton_click(t, e)
	{
		q('#status').html("componentButton pressed on client");
		//return false; // false to disable server handler call
	}
	
	function testCallShared_click(t, e)
	{
		shared().testSharedOnServer(1, "abc", function(e)
		{
			Lib.alert("callb = " + e);
		});
	}
	
	@shared function testSharedOnClient(a:Int, b:String) : Void
	{
		trace("client testShared");
	}
}
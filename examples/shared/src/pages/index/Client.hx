package pages.index;

import haquery.client.Lib;

class Client extends BaseClient
{
	function bt_click(t, e)
	{
		server().sharedServerMethod(10, 20, function(r)
		{
			Lib.alert("sharedServerMethod result = " + r);
		});
	}
    
	@shared function sharedClientMethod(a:Int, b:Int) : Void
	{
		Lib.alert("sharedClientMethod(" + a + ", " + b + ")");
	}
}
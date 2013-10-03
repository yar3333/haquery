package pages.index;

class Client extends BaseClient
{
	function bt_click(t, e)
	{
		server().sharedServerMethod(10, 20, function(r)
		{
			js.Browser.window.alert("sharedServerMethod result = " + r);
		});
	}
    
	@shared function sharedClientMethod(a:Int, b:Int) : Void
	{
		js.Browser.window.alert("sharedClientMethod(" + a + ", " + b + ")");
	}
}
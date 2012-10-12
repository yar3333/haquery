package pages.index;

import haquery.server.HaqPage;

class Server extends HaqPage
{
    function init()
	{
		trace("server init");
	}
	
	function simpleButton_click(t, e)
	{
		q('#status').html("simpleButton pressed on server");
	}
	
    function componentButton_click(t, e)
	{
		q('#status').html("componentButton pressed on server");
	}
	
	@shared function testShared(a:Int, b:String) : String
	{
		trace("server testShared");
		return "answer:" + a + "-" + b;
	}
}
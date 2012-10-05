package pages.index;

import haquery.server.HaqPage;

class Server extends HaqPage
{
    function simpleButton_click(t, e)
	{
		q('#status').html("simpleButton pressed on server");
	}
	
    function componentButton_click(t, e)
	{
		q('#status').html("componentButton pressed on server");
	}
	
	@shared("websocket") function testShared(a:Int, b:String) : String
	{
		return "answer:" + a + "-" + b;
	}
}
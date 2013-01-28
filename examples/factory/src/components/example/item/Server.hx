package components.example.item;

class Server extends BaseServer
{
    function init()
	{
		trace("server item.fullID = " + fullID);
	}
    
	function test_click(t, e)
    {
        trace("test_click on server " + fullID);
    }
}
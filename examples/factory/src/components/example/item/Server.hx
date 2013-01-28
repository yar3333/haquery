package components.example.item;

class Server extends BaseServer
{
    function init()
	{
		page.q("#status").html("server item.fullID = " + fullID);
	}
    
	function test_click(t, e)
    {
        page.q("#status").html("test_click on server " + fullID);
    }
}
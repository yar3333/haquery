package components.example.item;

class Client extends BaseClient
{
    function init()
	{
		trace("client item.fullID = " + fullID);
	}
	
	function test_click(t, e)
    {
        trace("test_click on client " + fullID);
    }
}
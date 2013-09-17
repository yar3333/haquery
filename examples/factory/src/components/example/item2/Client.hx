package components.example.item2;

class Client extends BaseClient
{
    function init()
	{
		page.q("#status").html("client item.fullID = " + fullID);
	}
	
	function test_click(t, e)
    {
        page.q("#status").html("test_click on client " + fullID);
    }
}
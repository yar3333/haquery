package pages.index;

class Client extends BaseClient
{
    function bt_click(t, e)
    {
        q('#status').html("bt_click client " + t.fullID);
    }
    
    function sbt_click(t, e)
    {
        q('#status').html("sbt_click client " + t.fullID);
    }
	
	function call_click(t, e)
	{
		server().test();
	}
}
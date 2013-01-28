package pages.index;

class Server extends BaseServer
{
	public function init()
	{
		if (!page.isPostback)
        {
            template().users.bind([
                 { login : "admin" }
                ,{ login : "user" }
            ]);
        }
	}
    
    function bt_click(t, e)
    {
        q('#status').html("bt_click server " + t.fullID);
    }
    
    function sbt_click(t, e)
    {
        q('#status').html("sbt_click server " + t.fullID);
    }
}
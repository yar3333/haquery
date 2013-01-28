package pages.index;

typedef User = 
{
    var login : String;
}

class Server extends BaseServer
{
	public function init()
	{
		if (!Lib.isPostback)
        {
            var users : Array<User> = [
                 { login : "admin" }
                ,{ login : "user" }
            ];
            trace("Users count = " + users.length);
            template().users.bind(users);
        }
	}
    
    function pagebt_click(t, e)
    {
        q('#status').html("pagebt_click server " + t.fullID);
    }
    
    function pagesbt_click(t, e)
    {
        q('#status').html("pagesbt_click server " + t.fullID);
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
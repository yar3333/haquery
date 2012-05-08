package pages.index;

import haquery.server.HaqPage;
import haquery.server.HaqComponent;
import haquery.server.Lib;

typedef User = {
    var login : String;
}

class Server extends HaqPage
{
	var template : TemplateServer;
	
	public function init()
	{
		if (!Lib.isPostback)
        {
            var users : Array<User> = [
                 { login : "admin" }
                ,{ login : "user" }
            ];
            trace("Users count = " + users.length);
            template.users.bind(users);
        }
	}
    
    function pagebt_click(t:HaqComponent, e)
    {
        q('#status').html("pagebt_click server " + t.fullID);
    }
    
    function pagesbt_click(t:HaqComponent, e)
    {
        q('#status').html("pagesbt_click server " + t.fullID);
    }
    
    function bt_click(t:HaqComponent, e)
    {
        q('#status').html("bt_click server " + t.fullID);
    }
    
    function sbt_click(t:HaqComponent, e)
    {
        q('#status').html("sbt_click server " + t.fullID);
    }
}
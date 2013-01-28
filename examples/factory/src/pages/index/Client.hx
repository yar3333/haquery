package pages.index;

typedef User = 
{
    var login : String;
}

class Client extends BaseClient
{
	function init()
	{
		template().users.create(template().table, { login : "admin" });
		template().users.create(template().table, { login : "user" });
		
		template().users2.create(template().table2, { login : "admin" });
		template().users2.create(template().table2, { login : "user" });
	}
	
	function pagebt_click(t, e)
    {
        q('#status').html("pagebt_click client " + t.fullID);
    }
    
    function pagesbt_click(t, e)
    {
        q('#status').html("pagesbt_click client " + t.fullID);
    }
    
    function bt_click(t, e)
    {
        q('#status').html("bt_click client " + t.fullID);
    }
    
    function sbt_click(t, e)
    {
        q('#status').html("sbt_click client " + t.fullID);
    }
}
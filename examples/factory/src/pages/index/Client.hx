package pages.index;

class Client extends BaseClient
{
	function init()
	{
		template().users.create(template().table, { login : "admin" });
		template().users.create(template().table, { login : "user" });
		
		template().users2.create(template().table2, { login : "admin" });
		template().users2.create(template().table2, { login : "user" });
		
		var user3_0 = template().users3.create(template().table3, {});
		var users3inner_0 : components.haquery.factory.Client = cast user3_0.components.get("users3inner");
		users3inner_0.create(user3_0.q("#tr3"), {});
		users3inner_0.create(user3_0.q("#tr3"), {});
		
		var user3_1 = template().users3.create(template().table3, {});
		var users3inner_1 : components.haquery.factory.Client = cast user3_1.components.get("users3inner");
		users3inner_1.create(user3_1.q("#tr3"), {});
		users3inner_1.create(user3_1.q("#tr3"), {});
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
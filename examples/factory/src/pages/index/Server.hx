package pages.index;

class Server extends BaseServer
{
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
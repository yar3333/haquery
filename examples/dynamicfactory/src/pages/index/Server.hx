package pages.index;

import haquery.server.HaqPage;
import haquery.server.HaqComponent;

class Server extends HaqPage
{
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
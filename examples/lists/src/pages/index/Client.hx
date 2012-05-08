package pages.index;

import haquery.client.HaqComponent;
import haquery.client.HaqPage;

class Client extends HaqPage
{
    function pagebt_click(t:HaqComponent, e)
    {
        q('#status').html("pagebt_click client " + t.fullID);
    }
    
    function pagesbt_click(t:HaqComponent, e)
    {
        q('#status').html("pagesbt_click client " + t.fullID);
    }
    
    function bt_click(t:HaqComponent, e)
    {
        q('#status').html("bt_click client " + t.fullID);
    }
    
    function sbt_click(t:HaqComponent, e)
    {
        q('#status').html("sbt_click client " + t.fullID);
    }
}
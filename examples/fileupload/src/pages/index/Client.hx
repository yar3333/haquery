package pages.index;

import haquery.client.HaqComponent;
import haquery.client.HaqPage;
import haquery.client.HaqSystem;

class Client extends HaqPage
{
    function fu_select(t:HaqComponent, e)
    {
        q('#status').html("select");
        trace("select");
    }
    
    function fu_filterNotMatch(t:HaqComponent, e)
    {
        q('#status').html("filterNotMatch");
        trace("filterNotMatch");
    }

    function fu_uploading(t:HaqComponent, e)
    {
        q('#status').html("uploading");
        trace("uploading");
    }
    
    function fu_sended(t:HaqComponent, e)
    {
        q('#status').html("complete");
        trace("complete");
    }
}
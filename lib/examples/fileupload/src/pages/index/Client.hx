package pages.index;

import haquery.client.HaqComponent;
import haquery.client.HaqPage;
import haquery.client.HaqSystem;

class Client extends HaqPage
{
    public function fu_select(t:HaqComponent)
    {
        q('#status').html("select");
        trace("select");
    }
    
    public function fu_filterNotMatch(t:HaqComponent)
    {
        q('#status').html("filterNotMatch");
        trace("filterNotMatch");
    }

    public function fu_uploading(t:HaqComponent)
    {
        q('#status').html("uploading");
        trace("uploading");
    }
    
    public function fu_sended(t:HaqComponent)
    {
        q('#status').html("complete");
        trace("complete");
    }
}
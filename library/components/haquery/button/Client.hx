package components.haquery.button;

import haquery.client.HaqEvent;

class Client extends Base
{
    var event_click : HaqEvent;
    
    function b_click(t, e)
    {
        return enabled ? event_click.call(e) : false;
    }
    
    public function click(t, e)
    {
        q('#b').click();
    }
}

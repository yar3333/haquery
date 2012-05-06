package components.haquery.button;

import haquery.client.HaqEvent;

class Client extends Base
{
    var event_click : HaqEvent;
    
    function b_click(t, e)
    {
        return enabled ? event_click.call() : false;
    }
    
    public function click()
    {
        q('#b').click();
    }
}

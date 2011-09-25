package haquery.components.button;

import haquery.client.HaqEvent;

class Client extends Base
{
    var event_click : HaqEvent;
    
    function b_click()
    {
        return enabled ? event_click.call() : false;
    }
}

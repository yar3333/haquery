package haquery.components.button;

import haquery.client.HaqEvent;

class Client extends Base
{
    public var event_click : HaqEvent;
    
    public function b_click()
    {
        return enabled ? event_click.call() : false;
    }
}

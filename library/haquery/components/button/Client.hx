package haquery.components.button;

import haquery.client.HaqEvent;

class Client extends Base
{
    var event_click : HaqEvent;
    
    function factoryInit()
    {
    }
    
    function b_click()
    {
        return enabled ? event_click.call() : false;
    }
    
    public function click()
    {
        q('#b').click();
    }
}

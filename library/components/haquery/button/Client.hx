package components.haquery.button;

import haquery.client.HaqEvent;

class Client extends Base
{
    var event_click : HaqEvent;
    
    function c_click()
    {
        return enabled ? event_click.call() : false;
    }
    
    public function click()
    {
        q('#c').click();
    }
}

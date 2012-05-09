package components.haquery.button;

import haquery.client.HaqEvent;
import js.JQuery;

class Client extends Base
{
    var event_click : HaqEvent<JqEvent>;
    
    function b_click(t, e:JqEvent)
    {
        return enabled ? event_click.call(e) : false;
    }
    
    public function click(t, e)
    {
        q('#b').click();
    }
}

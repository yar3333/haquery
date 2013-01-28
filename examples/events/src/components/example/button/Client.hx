package components.example.button;

import haquery.common.HaqEvent;
import js.JQuery;

class Client extends Base
{
    var event_click : HaqEvent<JqEvent>;
    
    function container_click(t, e)
    {
        return enabled ? event_click.call(e) : false;
    }
    
    public function click(t, e)
    {
        template().container.click();
    }
}

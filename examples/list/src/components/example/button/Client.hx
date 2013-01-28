package components.example.button;

import haquery.common.HaqEvent;
import js.JQuery;

class Client extends BaseClient
{
    var event_click : HaqEvent<JqEvent>;
    
    function container_click(t, e)
    {
        return event_click.call(e);
    }
}

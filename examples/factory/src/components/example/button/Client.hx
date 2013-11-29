package components.example.button;

import haquery.common.HaqEvent;
import js.JQuery;

class Client extends BaseClient
{
    var event_click : HaqEvent<JqEvent>;

    function new()
	{
		super();
		trace("button new");
	}
	
	function init()
	{
		trace("button init");
	}
	
    function container_click(t, e)
    {
        return event_click.call(e);
    }
}

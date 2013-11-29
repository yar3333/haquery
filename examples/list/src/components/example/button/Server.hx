package components.example.button;

import haquery.common.HaqEvent;

class Server extends BaseServer
{
	var event_click : HaqEvent<Dynamic>;

	public var text : String;
	
	function init()
	{
		trace("button server init");
	}
	
	function preRender()
	{
        template().container.html(text);
	}
	
	function container_click(t, e)
	{
		event_click.call(e);
	}
}

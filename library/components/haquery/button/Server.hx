package components.haquery.button;

import haquery.common.HaqEvent;
import haquery.Std;

class Server extends Base
{
	var event_click : HaqEvent<Dynamic>;

	public var text : String;
	public var cssClass : String;
	
	function preRender()
	{
        template().container
			.html(text)
			.addClass(cssClass);
	}
	
	function container_click(t, e)
	{
		event_click.call(e);
	}
	
	override function loadFieldValues(params:Hash<Dynamic>) 
	{
		super.loadFieldValues(params);
		
		if (params.exists("enabled"))
		{
			enabled = Std.bool(params.get("enabled"));
		}
	}
}

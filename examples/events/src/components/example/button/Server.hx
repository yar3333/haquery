package components.example.button;

import haquery.Std;
import haquery.common.HaqEvent;

class Server extends Base
{
	var event_click : HaqEvent<Dynamic>;

	public var text : String;
	public var cssClass : String;
	
	function preRender()
	{
        template().container.html(text);
		template().container.addClass(cssClass);
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

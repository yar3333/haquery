package components.haquery.button;

import haquery.Std;
import haquery.server.HaqEvent;

class Server extends Base
{
	var event_click : HaqEvent;

	public var text : String;
	public var cssClass : String;
	
	function preRender()
	{
        q('#b').html(text);
        q('#b').addClass(cssClass);
	}
	
	function b_click()
	{
        event_click.call();
	}
	
	override function loadFieldValues(params:Hash<String>) 
	{
		super.loadFieldValues(params);
		
		if (params.exists("enabled"))
		{
			enabled = Std.bool(params.get("enabled"));
		}
	}
}

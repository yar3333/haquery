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
        q('#b').html(text);
        q('#b').addClass(cssClass);
	}
	
	function b_click(t, e)
	{
		event_click.call(e);
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

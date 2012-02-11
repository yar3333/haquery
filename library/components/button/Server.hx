package haquery.components.button;

import php.Lib;
import haquery.server.HaqEvent;

class Server extends Base
{
	var event_click : HaqEvent;

	public var text : String;
	public var cssClass : String;
	public var style : String;
	public var hidden : Bool;
	
	function preRender()
	{
		if (text!=null) q('#b span').html(text);
		if (cssClass!=null) q('#b').addClass(cssClass);
		if (style!=null) q('#b').attr('style',style);
		if (hidden) q('#b').css('visibility','hidden');
	}

	function b_click()
	{
        event_click.call();
	}
}

package components.button;

import php.Lib;

import haquery.server.HaqComponent;
import haquery.server.HaqEvent;

class Server extends HaqComponent
{
	public var event_click : HaqEvent;

	public var text : String;
	public var clas : String;
	public var style : String;
	public var hidden : Bool;
	
	public function preRender()
	{
		if (text!=null) q('#t').html(text);
		if (clas!=null) q('#b').addClass(clas);
		if (style!=null) q('#t').attr('style',style);
		if (hidden) q('#b').css('visibility','hidden');
	}

	public function b_click()
	{
		this.event_click.call();
	}
}

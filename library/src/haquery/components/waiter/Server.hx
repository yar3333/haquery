package components.waiter;

import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    public var selector : String;
    public var cssClass : String;
    public var text : String;
	
    function preRender()
	{
		q('#shadow').attr('selector', selector);
        if (cssClass!=null) q('#shadow').addClass(cssClass);
        if (text!=null) q('#text').html(text);
	}
}
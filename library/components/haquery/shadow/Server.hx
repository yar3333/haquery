package components.haquery.shadow;

import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    public var cssClass : String;
	
    function preRender()
	{
        if (cssClass!=null) q('#shadow').addClass(cssClass);
	}
}
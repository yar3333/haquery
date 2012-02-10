#if php

package haquery.components.splitter;

import haquery.server.Lib;
import haquery.server.HaqComponent;

class Server extends HaqComponent
{
	public var style : String;
    
    public var firstSelector : String;
    public var secondSelector : String;

    function preRender()
    {
        if (firstSelector != null)
		{
			q('#a').val(firstSelector);
		}
		
		if (secondSelector != null)
		{
			q('#b').val(secondSelector);
		}
		
        if (style != null)
        {
            q('#s').attr('style', style);
        }
    }
}

#end
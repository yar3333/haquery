#if php

package components.buttonexample;

import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    var template : Template;
	
	function init()
    {
		template.status.html('pressed on server');
    }
}

#end
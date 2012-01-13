#if php

package components.mycomp;

import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    var template : Template;
	
	function init()
    {
		template.serverStatus.html('mycomp on the server');
    }
}

#end
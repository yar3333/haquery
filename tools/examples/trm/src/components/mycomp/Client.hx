#if js

package components.mycomp;

import haquery.client.HaqComponent;

class Client extends HaqComponent
{
	var template : Template;
	
    function init()
    {
        template.clientStatus.html('mycomp on the client');
    }
}

#end
#if js

package components.buttonexample;

import haquery.client.HaqComponent;

class Client extends HaqComponent
{
	var template : Template;
	
    function init()
    {
        template.status.html('pressed on client');
    }
}

#end
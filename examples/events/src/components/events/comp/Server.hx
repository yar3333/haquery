package components.events.comp;

import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    function innerSimpleButton_click()
	{
		q('#status').html("innerSimpleButton pressed on server");
	}
	
    function innerComponentButton_click()
	{
		q('#status').html("innerComponentButton pressed on server");
	}
}
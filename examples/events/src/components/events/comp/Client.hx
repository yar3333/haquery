package components.events.comp;

import haquery.client.HaqComponent;

class Client extends HaqComponent
{
	function innerSimpleButton_click(t, e)
	{
		q('#status').html("innerSimpleButton pressed on client");
	}
    
	function innerComponentButton_click(t, e)
	{
		q('#status').html("innerComponentButton pressed on client");
		//return false; // false to disable server handler call
	}    
}
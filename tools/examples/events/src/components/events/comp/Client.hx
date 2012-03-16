package components.events.comp;

import haquery.client.HaqComponent;

class Client extends HaqComponent
{
	public function innerSimpleButton_click()
	{
		q('#status').html("innerSimpleButton pressed on client");
	}
    
	public function innerComponentButton_click()
	{
		q('#status').html("innerComponentButton pressed on client");
		//return false; // false to disable server handler call
	}    
}
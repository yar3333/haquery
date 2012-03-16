package components.events.comp;

import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    public function innerSimpleButton_click()
	{
		q('#status').html("innerSimpleButton pressed on server");
	}
	
    public function innerComponentButton_click()
	{
		q('#status').html("innerComponentButton pressed on server");
	}
}
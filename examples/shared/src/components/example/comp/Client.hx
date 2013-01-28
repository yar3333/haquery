package components.example.comp;

class Client extends BaseClient
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
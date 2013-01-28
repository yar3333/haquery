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
		
		// uncomment to disable server handler call
		//return false; 
	}    
}
package pages.index;

class Client extends BaseClient
{
	function simpleButton_click(t, e)
	{
		q('#status').html("simpleButton pressed on client");
	}
    
	function componentButton_click(t, e)
	{
		q('#status').html("componentButton pressed on client");
		//return false; // false to disable server handler call
	}
}
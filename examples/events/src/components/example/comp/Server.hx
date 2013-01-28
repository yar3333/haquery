package components.example.comp;

class Server extends BaseServer
{
    function innerSimpleButton_click(t, e)
	{
		q('#status').html("innerSimpleButton pressed on server");
	}
	
    function innerComponentButton_click(t, e)
	{
		q('#status').html("innerComponentButton pressed on server");
	}
}
package pages.index;

import haquery.server.HaqPage;

class Server extends HaqPage
{
    function save_click(t, e)
	{
		q('#status').html("SAVED:<br />" + template().editor.text);
	}
}
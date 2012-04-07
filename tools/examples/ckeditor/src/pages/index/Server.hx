package pages.index;

import haquery.server.HaqPage;

class Server extends HaqPage
{
    var template : TemplateServer;
	
	function save_click()
	{
		q('#status').html("SAVED:<br />" + template.editor.text);
	}
}
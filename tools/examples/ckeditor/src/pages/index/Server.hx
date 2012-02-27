package pages.index;

import haquery.server.HaqPage;

class Server extends HaqPage
{
    var template : TemplateServer;
	
	public function save_click()
	{
		q('#status').html("SAVED:<br />" + template.editor.text);
	}
}
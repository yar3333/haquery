package pages.index;

import haquery.server.HaqPage;

class Server extends HaqPage
{
    public function save_click()
	{
		var editor : haquery.components.ckeditor.Server = cast components.get('editor');
		
		q('#status').html("SAVED:<br />" + editor.text);
	}
}
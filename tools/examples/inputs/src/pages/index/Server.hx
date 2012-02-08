package pages.index;

import haquery.server.HaqPage;
import haquery.server.Lib;

class Server extends HaqPage
{
	function preRender()
	{
		updateStatus();
	}
	
	function save_click()
	{
		updateStatus();
	}
	
	function updateStatus()
	{
		var checkbox : haquery.components.checkbox.Server = cast components.get("awesome");
		var radioboxes : haquery.components.radioboxes.Server = cast components.get("gender");
		q('#status').html("check = " + (checkbox.checked ? "true" : "false") + "; radio = " + radioboxes.value);
	}
}
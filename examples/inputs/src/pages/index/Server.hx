package pages.index;

import haquery.server.HaqPage;
import haquery.server.Lib;

class Server extends HaqPage
{
	function preRender()
	{
		updateStatus();
	}
	
	function save_click(t, e)
	{
		updateStatus();
	}
	
	function updateStatus()
	{
		q('#status').html(
			  "Status: "
			+ "check = " + (template().awesome.checked ? "true" : "false") + "; "
			+ "radio = " + (template().gender.value != null ? template().gender.value : "unselected")
		);
	}
}
package pages.index;

import haquery.server.HaqPage;
import haquery.server.Lib;

class Server extends HaqPage
{
	var template : TemplateServer;
	
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
			  "check = " + (template.awesome.checked ? "true" : "false") + "; "
			+ "radio = " + template.gender.value
		);
	}
}
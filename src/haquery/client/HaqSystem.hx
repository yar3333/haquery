package haquery.client;

import js.Dom.HtmlDom;
import js.Lib;
import jQuery.JQuery;
import haquery.client.HaqComponentManager;
import haquery.client.HaqTemplates;
import haquery.client.HaQuery;

class HaqSystem 
{
	public function new() : Void
	{
		var templates = new HaqTemplates(HaqInternals.componentsFolders, HaqInternals.serverHandlers);
		var manager = new HaqComponentManager(templates, HaqInternals.id_tag);
        manager.createPage();
	}
}
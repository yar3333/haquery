package haquery.client;

import haquery.client.HaqComponentManager;
import haquery.client.HaqComponentTemplates;

class HaqSystem 
{
	public static var page : HaqPage;
    
    public function new() : Void
	{
		var templates = new HaqComponentTemplates(HaqInternals.componentsFolders, HaqInternals.serverHandlers);
		var manager = new HaqComponentManager(templates, HaqInternals.id_tag);
        page = manager.createPage();
	}
}
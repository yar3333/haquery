package haquery.client;

import haquery.client.HaqComponentManager;
import haquery.client.HaqTemplates;

class HaqSystem 
{
	public static var page : HaqPage;
    
    public function new() : Void
	{
		var templates = new HaqTemplates(HaqInternals.componentsFolders, HaqInternals.serverHandlers);
		var manager = new HaqComponentManager(templates, HaqInternals.id_tag);
        page = manager.createPage();
	}
}
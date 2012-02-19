package haquery.client;

import haquery.client.HaqTemplateManager;

class HaqSystem 
{
	public static var page : HaqPage;
    
    public function new() : Void
	{
		var manager = new HaqTemplateManager();
        page = manager.createPage(HaqInternals.pageFullTag);
	}
}
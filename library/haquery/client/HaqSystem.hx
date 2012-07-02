package haquery.client;

import haquery.client.HaqTemplateManager;

class HaqSystem 
{
	public static var page : HaqPage;
    
    public static function run(pageFullTag:String)
	{
		new HaqSystem(pageFullTag);
	}
	
	function new(pageFullTag)
	{
		var manager = new HaqTemplateManager();
        manager.createPage(pageFullTag);
		page.forEachComponent("preInit", true);
		page.forEachComponent("init", false);
	}
}
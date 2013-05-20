package pages;

class Bootstrap extends haquery.server.HaqBootstrap
{
	override function start(request:haquery.server.HaqRequest)
	{
		// here you can tune configuration
		// config.customs.set("myKey", "myValue");
	}
    
    override function finish(page:haquery.server.BasePage)
    {
		// code to run after page processing
    }
}

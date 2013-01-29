package pages;

class Bootstrap extends haquery.server.HaqBootstrap
{
	override function init(request:haquery.server.HaqRequest)
	{
		// Here db is not yet connected. Tune config if need.
		// config.databaseConnectionString = "mySpecialConnection";
	}
    
	override function start()
    {
		// code to run before page processing
    }
    
    override function finish()
    {
		// code to run after page processing
    }
}
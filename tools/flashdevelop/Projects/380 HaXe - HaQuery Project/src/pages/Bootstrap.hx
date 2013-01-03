package pages;

import haquery.server.Lib;
import haquery.server.HaqRequest;

class Bootstrap extends haquery.server.HaqBootstrap
{
	override function init(request:HaqRequest)
	{
		// Here db is not yet connected. Tune Lib.config if need.
		// Lib.config.databaseConnectionString = "mySpecialConnection";
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
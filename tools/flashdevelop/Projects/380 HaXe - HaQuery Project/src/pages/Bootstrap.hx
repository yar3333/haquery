package pages;

import haquery.server.Lib;

class Bootstrap extends haquery.server.HaqBootstrap
{
    function new()
    {
       super();
       
       // tune Lib.config if need
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

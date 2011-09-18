package pages;

import haquery.server.HaqBootstrap;
import haquery.server.HaqConfig;
import haquery.server.HaQuery;

class Bootstrap implements HaqBootstrap
{
	public function init(config:HaqConfig) : Void
	{
		config.addComponentsFolder('components');
        
        config.layout = "support/layout.html";
	}
}

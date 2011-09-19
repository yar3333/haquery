package pages;

import haquery.server.HaqBootstrap;
import haquery.server.HaqConfig;

class Bootstrap implements HaqBootstrap $(CSLB){
	public function init(config:HaqConfig) : Void $(CSLB){
		config.addComponentsFolder('components');
	}
}

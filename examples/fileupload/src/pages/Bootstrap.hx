package pages;

import haquery.server.HaqBootstrap;
import haquery.server.HaqConfig;

class Bootstrap implements HaqBootstrap
{
    public function init(config:HaqConfig) : Void 
    {
        //config.componentsFolders.push('components');
    }
}
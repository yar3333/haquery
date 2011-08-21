package pages;

import haquery.server.HaqBootstrap;
import haquery.server.HaqConfig;
import haquery.server.HaQuery;

class Bootstrap implements HaqBootstrap
{
	public function init(config:HaqConfig) : Void
	{
		/*config.consts.set('title', 'Калькулятор онлайн');
		config.consts.set('copyrights', 'MicroCalc.ru');
		config.consts.set('email', 'admin@MicroCalc.ru');*/
		config.componentsFolders.push('components');
	}
}

package ;

import ImportComponents;

class Main 
{
	static function main() 
	{
		#if php
			untyped __php__("require_once dirname(__FILE__) . '/haquery/server/HaqProfiler.php';");
			haquery.server.HaQuery.assert(false);
			haquery.server.HaQuery.run();
		#end
 	}
}


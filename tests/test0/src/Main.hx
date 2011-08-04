package ;

#if php
import php.Lib;
import tests.HaqTemplatesTest;
import tests.HaqXmlTest;
import tests.HaqQueryTest;
import haquery.server.HaqProfiler;

import components1.randnum.Server;
#end

class Main
{
    static function main()
	{
		#if php
			untyped __php__("require_once dirname(__FILE__) . '/haquery/server/HaqProfiler.php';");
			
			var r = new haxe.unit.TestRunner();
			
			r.add(new HaqXmlTest());
			r.add(new HaqQueryTest());
			r.add(new HaqTemplatesTest());
			
			Lib.println("<pre>");
			r.run();
			Lib.println("</pre>");
		#end
	}
}

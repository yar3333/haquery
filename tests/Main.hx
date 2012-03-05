package ;

import Imports;

class Main
{
    static function main()
	{
		#if php
		
		var r = new haxe.unit.TestRunner();
		
		r.add(new HaqXmlTest());
		r.add(new tests.HaqQueryTest());
		r.add(new tests.HaqTemplatesTest());
		
		r.println("<pre>");
		r.run();
		r.println("</pre>");
		
		#end
	}
}

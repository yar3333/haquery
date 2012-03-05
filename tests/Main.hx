import Imports;

class Main
{
    static function main()
	{
		#if php
		
		var r = new haxe.unit.TestRunner();
		
		r.add(new models.HaqQueryTest());
		r.add(new models.HaqTemplatesTest());
		
		php.Lib.println("<pre>");
		r.run();
		php.Lib.println("</pre>");
		
		#end
	}
}

import Imports;

#if php
import php.Lib;
#elseif neko
import neko.Lib;
#end

class Main
{
    static function main()
	{
		#if !client
		
		var r = new haxe.unit.TestRunner();
		
		r.add(new models.HaqQueryTest());
		r.add(new models.HaqTemplatesTest());
		
		r.run();
		
		#end
	}
}

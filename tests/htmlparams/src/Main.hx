package ;

#if php
import php.Web;
import php.Lib;
#elseif neko
import neko.Web;
import neko.Lib;
#end

class Main
{
    static function main()
	{
		var r = new haxe.unit.TestRunner();
		r.add(new HtmlParamsTest());
		r.run();
	}
}

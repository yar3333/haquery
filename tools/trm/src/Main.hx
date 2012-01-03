package ;

import php.FileSystem;
import php.Lib;
import php.Sys;

using haquery.StringTools;

class Main 
{
	static function main() 
	{
		var args = Sys.args();
		
		if (args.length != 1)
		{
			Lib.println("You must specify argument: components_package.");
			Sys.exit(1);
		}
		
		TrmGenerator.makeForComponents(args[0]);
		//TrmGenerator.makeForPages();
	}
}

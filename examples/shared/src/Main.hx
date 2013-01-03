import Imports;

class Main 
{
	static function main() 
	{
		#if server
        haquery.server.Lib.run();
		#end
 	}
}

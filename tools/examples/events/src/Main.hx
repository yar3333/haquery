import Imports;

class Main 
{
	static function main() 
	{
		#if !client
        haquery.server.Lib.run();
		#end
 	}
}

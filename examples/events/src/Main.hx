import Imports;

#if !client
import components.macrotests.c.Server;
#else
import components.macrotests.c.Client;
#end

class Main 
{
	static function main() 
	{
		#if !client
        haquery.server.Lib.run();
		#end
 	}
}

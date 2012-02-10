package ;

import php.FileSystem;
import php.Lib;
import php.Sys;
import haquery.server.db.HaqDb;

class Main 
{
	static function main() 
	{
		var args = Sys.args();
		
		if (args.length != 2)
		{
			Lib.println("You must specify arguments: connection_string path_to_src.");
			Sys.exit(1);
		}
		
		var re = new EReg('^([a-z]+)\\://([_a-zA-Z0-9]+)\\:(.+?)@([_a-zA-Z0-9]+)/([_a-zA-Z0-9]+)$', '');
		if (!re.match(args[0]))
		{
			Lib.println("Connection string example: 'mysql://root:123456@localhost/test'.");
			Sys.exit(1);
		}
		
		if (!FileSystem.isDirectory(args[1]))
		{
			Lib.println("Directory " + args[1] + " not found.");
			Sys.exit(1);
		}
		
		HaqDb.connect({
             type : re.matched(1)
            ,user : re.matched(2)
            ,pass : re.matched(3)
            ,host : re.matched(4)
            ,database : re.matched(5)
        });
		OrmGenerator.make(args[1]);
	}

}
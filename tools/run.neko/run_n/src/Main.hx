import haquery.Tasks;
import neko.Lib;
import neko.Sys;

class Main 
{
	static function main() 
	{
        var args = Sys.args();
        
		var exeDir = Sys.getCwd();
        
		if (args.length > 0)
		{
			
			Sys.setCwd(args.pop());
		}
		else
		{
			Lib.println("To run this program use haxelib utility.");
			return 1;
		}
		
		var haquery = new haquery.Tasks(exeDir);
        
        switch (args.length > 0 ? args[0] : '')
        {
            case 'gen-orm': 
				if (args.length > 1)
				{
					haquery.genOrm(args[1]);
				}
				else
				{
					Lib.println("Database connection string must be specified (format: 'mysql://USER:PASSWORD@HOST/DATABASE').");
					return 1;
				}
            
			case 'pre-build': 
                haquery.preBuild();
            
            case 'post-build': 
				var skipJS = false;
				var skipComponents = false;
				for (arg in args.slice(1))
				{
					if (arg == "--skipjs")
					{
						skipJS = true;
					}
					else
					if (arg == "--skipcomponents")
					{
						skipComponents = true;
					}
					else
					{
						Lib.println("Option '" + arg + "' is not supported.");
						return 1;
					}
				}
				haquery.postBuild(skipJS, skipComponents);
                
            case 'install':
                haquery.install();
            
            case 'uninstall':
                haquery.uninstall();
            
            default:
				Lib.println("HaQuery building support and deploying tool.");
				Lib.println("Usage: haquery <command>");
				Lib.println("\twhere <command> may be:");
				Lib.println("\t\tgen-orm <databaseConnectionString>       Generate object-related classes (managers and models)");
				Lib.println("\t\tgen-trm <componentsPackage>              Generate template-related classes");
				Lib.println("\t\tpre-build                                Do pre-build step");
				Lib.println("\t\tpost-build [--skipjs] [--skipcomponents] Do post-build step");
				Lib.println("\t\tinstall                                  Patch haXe librarires to HaxeMod");
				Lib.println("\t\tuninstall                                Restore original haXe libraries");
                return 1;
        }
        
        return 0;
	}
}
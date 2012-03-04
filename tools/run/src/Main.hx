package ;

import haquery.server.HaqConfig;
import neko.Lib;
import neko.Sys;
import haquery.tools.Tasks;

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
		
		var tasks = new Tasks(exeDir);
        
        switch (args.length > 0 ? args[0] : '')
        {
            case 'gen-orm': 
				tasks.genOrm(args.length > 1 ? args[1] : HaqConfig.readDatabaseConnectionString("src/config.xml"), 'src');
            
            case 'gen-trm': 
				tasks.genTrm();
			
			case 'pre-build': 
                tasks.preBuild();
            
            case 'post-build': 
				return tasks.postBuild() ? 0 : 1;
                
            case 'install':
                tasks.install();
            
            default:
				Lib.println("HaQuery building support and deploying tool.");
				Lib.println("Usage: haquery <command>");
				Lib.println("\twhere <command> may be:");
				Lib.println("\t\tgen-orm <databaseConnectionString>  Generate object-related classes (managers and models)");
				Lib.println("\t\tgen-trm <componentsPackage>         Generate template-related classes");
				Lib.println("\t\tpre-build                           Do pre-build step");
				Lib.println("\t\tpost-build                          Do post-build step");
				Lib.println("\t\tinstall                             Install FlashDevelop templates and apply a minor patch to upgrade haXe library");
                return 1;
        }
        
        return 0;
	}
}
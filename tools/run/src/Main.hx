package ;

import haquery.server.HaqConfig;
import haquery.tools.FlashDevelopProject;
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
				var project = new FlashDevelopProject("", exeDir);
				tasks.genOrm(args.length > 1 ? args[1] : HaqConfig.readDatabaseConnectionString(project.srcPath + "config.xml"), project.srcPath);
			
			case 'pre-build': 
                tasks.preBuild();
            
            case 'post-build': 
				return tasks.postBuild() ? 0 : 1;
                
            case 'install':
                tasks.install();
            
            default:
				Lib.println("HaQuery building support and deploying tool.");
				Lib.println("Usage: haxelib run HaQuery <command>");
				Lib.println("\twhere <command> may be:");
				Lib.println("\t\tpre-build                           Do pre-build step.");
				Lib.println("\t\tpost-build                          Do post-build step.");
				Lib.println("\t\tinstall                             Install FlashDevelop templates and apply a minor patch to haXe std library.");
				Lib.println("\t\tgen-orm [databaseConnectionString]  Generate object-related classes (managers and models).");
                return 1;
        }
        
        return 0;
	}
}
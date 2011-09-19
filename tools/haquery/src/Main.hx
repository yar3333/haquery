import haquery.Tasks;
import neko.Lib;
import neko.Sys;

class Main 
{
	static function main() 
	{
        var args = Sys.args();
        
        var haquery = new haquery.Tasks();
        
        switch (args.length > 0 ? args[0] : '')
        {
            case 'gen-orm': 
                haquery.genOrm(args[1]);
            
            case 'pre-build': 
                haquery.preBuild();
            
            case 'post-build': 
                haquery.postBuild();
                
            case 'install':
                haquery.install();
            
            case 'uninstall':
                haquery.uninstall();
            
            default:
                Lib.println('HaQuery building support and deploying tool.');
                Lib.println('Usage: haquery <command>');
                Lib.println('\t where <command> may be:');
                Lib.println('\t\tgen-orm <databaseConnectionString>    Generate tables-related classes to model folder.');
                Lib.println('\t\tpre-build                             Do pre-build step.');
                Lib.println('\t\tpost-build                            Do post-build step.');
                Lib.println('\t\tinstall                               Replace official haxe.exe and librarires to HaxeMod.');
                Lib.println('\t\tuninstall                             Restore official haxe.exe and libraries.');
                return 1;
        }
        
        return 0;
	}
}
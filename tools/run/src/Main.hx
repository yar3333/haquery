import neko.FileSystem;
import neko.Lib;
import neko.Sys;

class Main 
{
	static function main() 
	{
        var args = Sys.args();
        
        Lib.println("Run.n start");
        
        var pathToHaqueryExe = FileSystem.fullPath(".\\bin\\haquery.exe");
        Lib.println("pathToHaqueryExe = " + pathToHaqueryExe);
        if (!FileSystem.exists(pathToHaqueryExe))
        {
            Lib.println("File not found: " + pathToHaqueryExe);
            return 1;
        }
        Sys.setCwd(args.pop());
        Sys.command(pathToHaqueryExe, args);
        
        return 0;
	}
}
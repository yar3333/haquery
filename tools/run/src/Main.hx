import neko.FileSystem;
import neko.io.Process;
import neko.Lib;
import neko.Sys;

class Main 
{
	static function main() 
	{
        var args = Sys.args();
        
        Lib.println("Run.n start");
        
        var pathToHaqueryExe = FileSystem.fullPath(".\\bin\\haquery.exe");
        if (!FileSystem.exists(pathToHaqueryExe))
        {
            Lib.println("File not found: " + pathToHaqueryExe);
            return 1;
        }
        Sys.setCwd(args.pop());
        
        var p = new Process(pathToHaqueryExe, args) ;
        var s = Std.string(p.stdout.readAll());
        Lib.print(StringTools.replace(s, "\r\n", "\n"));
        return p.exitCode();
	}
}
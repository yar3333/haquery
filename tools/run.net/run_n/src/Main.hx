import neko.FileSystem;
import neko.io.Process;
import neko.Lib;
import neko.Sys;

class Main 
{
	static function main() 
	{
        var args = Sys.args();
        
        var runExePath = FileSystem.fullPath("run.exe");
        if (!FileSystem.exists(runExePath))
        {
            Lib.println("File not found: " + runExePath);
            return 1;
        }
        
        Sys.setCwd(args.pop());
        
        var p = new Process(runExePath, args) ;
        var s = Std.string(p.stdout.readAll());
        Lib.print(StringTools.replace(s, "\r\n", "\n"));
        
        return p.exitCode();
	}
}
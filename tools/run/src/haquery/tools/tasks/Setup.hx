package haquery.tools.tasks;

import neko.zip.Uncompress;
import neko.Sys;

import haquery.server.FileSystem;
import haquery.server.io.File;
import haquery.server.io.Path;
import haquery.server.Lib;

import haquery.tools.Log;
import haquery.tools.Hant;

using haquery.StringTools;

class Setup 
{
	var exeDir : String;
	
	var log : Log;
    var hant : Hant;
    
	public function new(exeDir:String)
	{
		this.exeDir = exeDir.replace('\\', '/').rtrim('/') + '/';
        
		log = new Log(2);
        hant = new Hant(log, this.exeDir);
	}
	
	public function install()
    {
		try
		{
			installFlashDevelopTemplates();
			installHaxePatch();
		}
		catch (e:Dynamic)
		{
			Lib.println(e);
			Lib.println("HaQuery installation to the system was aborted. Ensure what you run this program under administrator account.");
		}
    }
    
    function installFlashDevelopTemplates()
    {
        log.start('Install FlashDevelop templates');
        
        var srcPath = exeDir + "tools/flashdevelop.zip";
        var userLocalPath = Sys.getEnv('LOCALAPPDATA') != null 
            ? Sys.getEnv('LOCALAPPDATA') 
            : Sys.getEnv('USERPROFILE') + '/Local Settings/Application Data';
        var flashDevelopUserDataPath = userLocalPath.replace('\\', '/') + '/FlashDevelop';
        
		unzip(srcPath, flashDevelopUserDataPath, false);
        
        log.finishOk();
    }
    
    function installHaxePatch()
    {
        log.start('Install HaxePatch');
		
		log.print("std/js/_std/EReg.hx\tVersion from haXe 2.08+ (chrome browser bugfixes)");
		log.print("std/php/_std/Date.hx\tVersion from haXe 2.08+ (microtime() instead time())");
        
        unzip(exeDir + "tools/haxepatch.zip", hant.getHaxePath(), true);
        
        log.finishOk();
    }
    
    function unzip(zipPath:String, targetPath:String, isMakeBackup:Bool)
	{
		var fin = neko.io.File.read(zipPath, true);
		var files = neko.zip.Reader.readZip(fin);
		fin.close();

		for (file in files)
		{
			hant.createDirectory(targetPath + '/' + Path.directory(file.fileName));
			
			if (isMakeBackup && FileSystem.exists(targetPath + '/' + file.fileName))
			{
				FileSystem.rename(targetPath + '/' + file.fileName, targetPath + '/' + file.fileName + ".haquery.bak");
			}
			
			var fout = File.write(targetPath + '/' + file.fileName, true);
			var data = Uncompress.run(file.data);
			fout.writeBytes(data, 0, data.length);
			fout.close();
		}
	}
}
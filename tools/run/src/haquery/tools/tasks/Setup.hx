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
	var haxePath:String;
	
	var log : Log;
    var hant : Hant;
    
	public function new(exeDir:String, haxePath:String)
	{
		this.exeDir = exeDir.replace('\\', '/').rtrim('/') + '/';
		this.haxePath = haxePath.replace('\\', '/').rtrim('/') + '/';
        
		log = new Log(2);
        hant = new Hant(log, this.exeDir);
	}
	
	public function install()
    {
		try
		{
			installFlashDevelopTemplates();
			installHaxeMod();
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
        
		unzip(srcPath, flashDevelopUserDataPath);
        
        log.finishOk();
    }
    
    function installHaxeMod()
    {
        log.start('Install HaxeMod');
        
        if (!FileSystem.exists(haxePath + 'std.original'))
        {
            hant.rename(haxePath + 'std', haxePath + 'std.original');
			
			var destPath = haxePath + "std";
			hant.createDirectory(destPath);
            unzip(exeDir + "tools/haxemod.zip", destPath);
        }
        
        log.finishOk();
    }
    
    public function uninstall()
    {
		try
		{
			uninstallFlashDevelopTemplates();
			uninstallHaxeMod();
		}
		catch (e:Dynamic)
		{
			Lib.println(e);
			Lib.println("HaQuery uninstallation was aborted. Ensure what you run this program under administrator account.");
		}
    }
    
    function uninstallFlashDevelopTemplates()
    {
        //log.start('Uninstall FlashDevelop templates');
        
        //log.finishOk();
    }
    
    function uninstallHaxeMod()
    {
        log.start('Uninstall HaxeMod');
        
        if (FileSystem.exists(haxePath + 'std.original'))
        {
            hant.deleteDirectory(haxePath + 'std');
            hant.rename(haxePath + 'std.original', haxePath + 'std');
        }
        
        log.finishOk();
    }
    
    function unzip(zipPath:String, targetPath:String)
	{
		var fin = neko.io.File.read(zipPath, true);
		var files = neko.zip.Reader.readZip(fin);
		fin.close();

		for (file in files)
		{
			hant.createDirectory(targetPath + '/' + Path.directory(file.fileName));
			var fout = File.write(targetPath + '/' + file.fileName, true);
			var data = Uncompress.run(file.data);
			fout.writeBytes(data, 0, data.length);
			fout.close();
		}
	}
}
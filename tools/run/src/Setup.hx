package ;

import neko.Lib;
import neko.zip.Reader;
import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import hant.Log;
import hant.Hant;
import hant.PathTools;
using haquery.StringTools;

class Setup 
{
	var log : Log;
    var hant : Hant;
	var exeDir : String;
    
	public function new(log:Log, hant:Hant, exeDir:String)
	{
		this.log = log;
		this.hant = hant;
		this.exeDir = PathTools.path2normal(exeDir) + "/";
	}
	
	public function install()
    {
		try
		{
			installFlashDevelopTemplates();
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
        
        var srcPath = exeDir + "flashdevelop.zip";
        var userLocalPath = Sys.getEnv('LOCALAPPDATA') != null 
            ? Sys.getEnv('LOCALAPPDATA') 
            : Sys.getEnv('USERPROFILE') + '/Local Settings/Application Data';
        var flashDevelopUserDataPath = userLocalPath.replace('\\', '/') + '/FlashDevelop';
        
		if (FileSystem.exists(flashDevelopUserDataPath))
		{
			unzip(srcPath, flashDevelopUserDataPath, false);
			log.finishOk();
		}
		else
		{
			try
			{
				log.finishFail("User folder for FlashDevelop templates not found. Before install FlashDevelop templates, ensure FlashDevelop installed and runned at least once.");
			}
			catch (e:String)
			{
				log.trace(e);
			}
		}
    }
    
    function unzip(zipPath:String, targetPath:String, isMakeBackup:Bool)
	{
		targetPath = targetPath.rtrim("\\/");
		
		var fin = neko.io.File.read(zipPath, true);
		var files = neko.zip.Reader.readZip(fin);
		fin.close();

		for (file in files)
		{
			if (!file.fileName.endsWith("/"))
			{
				log.start(file.fileName);
				
				var destFilePath = targetPath + '/' + file.fileName;
				
				hant.createDirectory(Path.directory(destFilePath));
				
				if (isMakeBackup && FileSystem.exists(destFilePath))
				{
					var bakFilePath = destFilePath + ".haquery.bak";
					if (!FileSystem.exists(bakFilePath))
					{
						FileSystem.rename(destFilePath, bakFilePath);
					}
				}
				
				var fout = File.write(destFilePath, true);
				fout.write(Reader.unzip(file));
				fout.close();
				
				log.finishOk();
			}
		}
	}
}
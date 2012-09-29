package haquery.tools.tasks;

import neko.Lib;
import neko.zip.Reader;
import haquery.server.FileSystem;
import haxe.io.Path;
import sys.io.File;

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
				log.print(e);
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
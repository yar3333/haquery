import neko.Lib;
import haxe.zip.Reader;
import sys.io.File;
import sys.FileSystem;
import hant.Log;
import hant.FileSystemTools;
import hant.Path;
using stdlib.StringTools;

class Setup 
{
	var exeDir : String;
    
	public function new(exeDir:String)
	{
		this.exeDir = Path.normalize(exeDir) + "/";
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
        Log.start('Install FlashDevelop templates');
        
        var srcPath = exeDir + "flashdevelop.zip";
        var userLocalPath = Sys.getEnv('LOCALAPPDATA') != null 
            ? Sys.getEnv('LOCALAPPDATA') 
            : Sys.getEnv('USERPROFILE') + '/Local Settings/Application Data';
        var flashDevelopUserDataPath = userLocalPath.replace('\\', '/') + '/FlashDevelop';
        
		if (FileSystem.exists(flashDevelopUserDataPath))
		{
			unzip(srcPath, flashDevelopUserDataPath, false);
			Log.finishSuccess();
		}
		else
		{
			try
			{
				Log.finishFail("User folder for FlashDevelop templates not found. Before install FlashDevelop templates, ensure FlashDevelop installed and runned at least once.");
			}
			catch (e:String)
			{
				Log.echo(e);
			}
		}
    }
    
    function unzip(zipPath:String, targetPath:String, isMakeBackup:Bool)
	{
		targetPath = targetPath.rtrim("\\/");
		
		var fin = File.read(zipPath, true);
		var files = Reader.readZip(fin);
		fin.close();

		for (file in files)
		{
			if (!file.fileName.endsWith("/"))
			{
				Log.start(file.fileName);
				
				var destFilePath = targetPath + '/' + file.fileName;
				
				FileSystemTools.createDirectory(Path.directory(destFilePath), false);
				
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
				
				Log.finishSuccess();
			}
		}
	}
}
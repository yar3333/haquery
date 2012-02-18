package haquery.tools;

import neko.FileSystem;
import neko.io.File;
import neko.Sys;
import neko.Lib;
import neko.io.Process;

using StringTools;

class Hant 
{
    var log : Log;
	var exeDir : String;
    
    public function new(log:Log, exeDir:String)
    {
        this.log = log;
		this.exeDir = exeDir;
    }
    
    public function findFiles(path:String, include:String->Bool) : Array<String>
    {
        var r : Array<String> = new Array<String>();
        
        for (file in FileSystem.readDirectory(path))
        {
            if (include(path + '/' + file))
            {
                if (FileSystem.isDirectory(path + '/' + file))
                {
                    r = r.concat(findFiles(path + '/' + file, include));
                }
                else
                {
                    r.push(path + '/' + file);
                }
            }
        }
        
        return r;
    }
    
    public function createDirectory(path:String)
    {
        log.start("Create directory '" + path + "'");
        try
        {
            path = path.replace('\\', '/');
            var dirs : Array<String> = path.split('/');
            for (i in 0...dirs.length)
            {
                var dir = dirs.slice(0, i + 1).join('/');
                if (!dir.endsWith(':'))
                {
                    if (!FileSystem.exists(dir))
                    {
                        FileSystem.createDirectory(dir);
                    }
                }
            }
            log.finishOk();
        }
        catch (message:String)
        {
            log.finishFail(message);
        }
    }
    
    public function copyFolderContent(fromFolder:String, toFolder:String, include:String->Bool)
    {
        log.start("Copy directory '" + fromFolder + "' => '" + toFolder + "'");
        try
        {
            for (file in FileSystem.readDirectory(fromFolder))
            {
                if (include(fromFolder + '/' + file))
                {
                    if (FileSystem.isDirectory(fromFolder + '/' + file))
                    {
                        copyFolderContent(fromFolder + '/' + file, toFolder + '/' + file, include);
                    }
                    else
                    {
                        if (!FileSystem.exists(toFolder)) createDirectory(toFolder);
                        
                        try
                        {
                            copyFile(fromFolder + '/' + file, toFolder + '/' + file);
                        }
                        catch (message:String)
                        {
                            Lib.println(message);
                        }
                    }
                }
            }
            log.finishOk();
        }
        catch (message:String)
        {
            log.finishFail(message);
        }
    }
    
    public function copyFile(src:String, dst:String)
    {
        log.start("Copy file '" + src + "' => '" + dst + "'");
        try
        {
            File.copy(src, dst);
            log.finishOk();
        }
        catch (message:String)
        {
            log.finishFail(message);
        }
    }
    
    public function rename(path:String, newpath:String)
    {
        log.start("Rename '" + path + "' => '" + newpath + "'");
        try
        {
            if (FileSystem.exists(path))
            {
                if (!FileSystem.isDirectory(path))
				{
					if (FileSystem.exists(newpath))
					{
						FileSystem.deleteFile(newpath);
					}
					FileSystem.rename(path, newpath);
				}
				else
				{
					if (FileSystem.exists(newpath))
					{
						FileSystem.deleteDirectory(newpath);
					}
					FileSystem.rename(path, newpath);
				}
            }
            else
            {
                throw "File '" + path + "' not found.";
            }
            log.finishOk();
        }
        catch (message:String)
        {
            log.finishFail(message);
        }
    }
    
    public function deleteDirectory(path:String)
    {
        if (FileSystem.exists(path))
		{
			log.start("Delete directory '" + path + "'");
			try
			{
				for (file in FileSystem.readDirectory(path))
				{
					if (FileSystem.isDirectory(path + '/' + file))
					{
						deleteDirectory(path + '/' + file);
					}
					else
					{
						deleteFile(path + '/' + file);
					}
				}

				FileSystem.deleteDirectory(path);
				log.finishOk();
			}
			catch (message:String)
			{
				log.finishFail(message);
			}
		}
    }
    
    public function deleteFile(path:String)
    {
        log.start("Delete file '" + path + "'");
        try
        {
            FileSystem.deleteFile(path);
            log.finishOk();
        }
        catch (message:String)
        {
            log.finishFail(message);
        }
    }
	
	public function run(fileName:String, args:Array<String>) : Int
	{
		try
		{
			var p : Process = new Process(fileName, args);
			var r = p.exitCode();
			Lib.println(p.stdout.readAll().toString()); 
			Lib.println(p.stderr.readAll().toString()); 
			p.close();
			return r;
		}
		catch (e:Dynamic)
		{
			Lib.println("Error: file '" + fileName + "' not found. Maybe you need to add directory to the PATH system environment variable.");
			throw e;
		}
	}
    
    /*public function getWindowsRegistryValue(key:String) : String
    {
        var dir = neko.Sys.getEnv("TMP");
		if (dir == null)
        {
			dir = "."; 		
        }
        var temp = dir + "/hant-tasks-get_windows_registry_value.txt";
		if (neko.Sys.command('regedit /E "' + temp + '" "' + key + '"') != 0) 
        {
			// might fail without appropriate rights
			return null;
		}
		// it's possible that if registry access was disabled the proxy file is not created
		var content = try neko.io.File.getContent(temp) catch ( e : Dynamic ) return null;
        content = content.replace("\x00", "").replace('\r', '').replace('\\\\', '\\');
		neko.FileSystem.deleteFile(temp);
        
        var re = new EReg('^@="(.*)"$', 'm');
        if (re.match(content)) return re.matched(1);
        
        return content;
    }*/
	
	public function restoreFileTime(fromPath:String, toPath:String)
	{
		run(exeDir + "restorefiletime.exe", [ fromPath.replace('/', '\\'), toPath.replace('/', '\\') ]);
	}
	
}
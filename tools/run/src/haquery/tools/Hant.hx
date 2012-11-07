package haquery.tools;

import neko.FileSystem;
import neko.io.File;
import neko.Sys;
import neko.Lib;
import neko.io.Process;

using haquery.StringTools;

class Hant 
{
    var log : Log;
	var exeDir : String;
    
    public function new(log:Log, exeDir:String)
    {
        this.log = log;
		this.exeDir = exeDir;
    }
    
    public function findFiles(path:String, ?onFile:String->Void, ?onDir:String->Bool) : Void
    {
		if (FileSystem.exists(path))
		{
			if (FileSystem.isDirectory(path))
			{
				for (file in FileSystem.readDirectory(path))
				{
					if (FileSystem.isDirectory(path + '/' + file))
					{
						if (onDir == null || onDir(path + '/' + file))
						{
							findFiles(path + '/' + file, onFile, onDir);
						}
					}
					else
					{
						if (onFile != null) onFile(path + '/' + file);
					}
				}
			}
			else
			{
				if (onFile != null) onFile(path);
			}
		}
    }
    
    public function createDirectory(path:String)
    {
        if (!FileSystem.exists(path))
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
    }
    
    public function copyFolderContent(src:String, dest:String)
    {
		src = src.replace('\\', '/').rtrim('/');
        dest = dest.replace('\\', '/').rtrim('/');
		
		log.start("Copy directory '" + src + "' => '" + dest + "'");
        
		findFiles(src, function(path)
		{
			HaqNative.copyFilePreservingAttributes(exeDir, path, dest + path.substr(src.length));
		});
		
		log.finishOk();
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
        if (FileSystem.exists(path))
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
    }
	
	public function deleteAny(path:String)
	{
		if (FileSystem.exists(path))
		{
			if (FileSystem.isDirectory(path))
			{
				deleteDirectory(path);
			}
			else
			{
				deleteFile(path);
			}
		}
	}
	
	public function run(fileName:String, args:Array<String>) : { exitCode:Int, stdOut:String, stdErr:String }
	{
		var p = new Process(fileName.replace("/", "\\"), args);
		
		var stdOut = "";
		try
		{
			while (true)
			{
				Sys.sleep(0.1);
				stdOut += p.stdout.readLine() + "\n";
			}
		}
		catch (e:haxe.io.Eof) {}
		
		var exitCode = p.exitCode();
		var stdErr = p.stderr.readAll().toString().replace("\r\n", "\n");
		p.close();
		
		if (exitCode != 0)
		{
			Lib.println(fileName.replace("/", "\\") + " " + args.join(" ") + " ");
			Lib.println("Run error: " + exitCode);
		}
		
		return { exitCode:exitCode, stdOut:stdOut, stdErr:stdErr };
	}
	
	/*public function runCmd(fileName:String, args:Array<String>)
	{
		var env = Sys.environment();
		if (!env.exists("ComSpec") || !FileSystem.exists(env.get("ComSpec")))
		{
			throw "Command processor not found (please, set 'ComSpec' environment variable).";
		}
		return run(env.get("ComSpec"), [ "/C", fileName.replace("/", "\\") ].concat(args));
	}*/
    
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
	
	public function restoreFileTimes(src:String, dest:String, ?filter:EReg)
	{
		findFiles(src, function(srcFile)
		{
			if (filter == null || filter.match(srcFile))
			{
				var destFile = dest + srcFile.substr(src.length);
				if (File.getContent(srcFile) == File.getContent(destFile))
				{
					rename(srcFile, destFile);
				}
			}
		});
	}
	
	public function getHaxePath()
    {
        var r = Sys.getEnv('HAXEPATH');
        
        if (r == null)
        {
            throw "HaXe not found (HAXEPATH environment variable not set).";
        }
		
		r = r.replace("\\", "/");
        while (r.endsWith('/'))
        {
            r = r.substr(0, r.length - 1);
        }
        r += '/';
        
        if (!FileSystem.exists(r + 'haxe.exe'))
        {
            throw "HaXe not found (file '" + r + "haxe.exe' does not exist).";
        }
        
        return r;
    }
}
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
    
    public function copyFolderContent(fromFolder:String, toFolder:String, excludeRegExp:String="")
    {
		fromFolder = fromFolder.replace('\\', '/').rtrim('/');
        toFolder = toFolder.replace('\\', '/').rtrim('/');
		
		log.start("Copy directory '" + fromFolder + "' => '" + toFolder + "'");
        
		run(exeDir + "copyfolder.exe", [ fromFolder.replace("/", "\\"), toFolder.replace("/", "\\"), excludeRegExp ]);
		
		log.finishOk();
    }
    
    /*public function copyFile(src:String, dst:String)
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
    }*/
    
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
	
	function run(fileName:String, args:Array<String>) : Int
	{
		Lib.print(fileName.replace("/", "\\") + " " + args.join(" ") + " ");
		
		var p = new Process(fileName.replace("/", "\\"), args);
		var r = p.exitCode();
		var out = (p.stdout.readAll().toString().replace("\r\n", "\n") + p.stderr.readAll().toString().replace("\r\n", "\n")).trim();
		if (out != "")
		{
			Lib.println("\n" + out); 
		}
		p.close();
		if (r != 0)
		{
			Lib.println("run error: " + r);
		}
		return r;
	}
	
	public function runWaiter(fileName:String, args:Array<String>, waitTimeMS:Int) : Int
	{
		return run(exeDir + "runwaiter.exe", [ Std.string(waitTimeMS), fileName.replace("/", "\\") ].concat(args));
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
	
	public function restoreFileTime(fromPath:String, toPath:String)
	{
		run(exeDir + "restorefiletime.exe", [ fromPath.replace('/', '\\'), toPath.replace('/', '\\') ]);
	}
	
}
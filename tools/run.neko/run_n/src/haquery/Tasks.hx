package haquery;

import neko.io.File;
import neko.io.FileOutput;
import neko.io.Path;
import neko.io.Process;
import neko.Sys;
import neko.Lib;
import neko.FileSystem;
import neko.zip.Uncompress;

using StringTools;

class Tasks 
{
    var log : hant.Log;
    var hant : hant.Tasks;
	var exeDir : String;
    
    public function new()
    {
        log = new hant.Log(2);
        hant = new hant.Tasks(log);
		exeDir = Path.directory(Sys.executablePath()).replace('\\', '/');
    }
    
    function genImports()
    {
        log.start("Generate imports to 'src/Imports.hx'");
        
        var fo : FileOutput = File.write("src/Imports.hx", false);
        
        for (path in getClassPaths())
        {
            fo.writeString("// " + path + "\n");
            genImportsInner(fo, path);
            fo.writeString("\n");
        }
        
        fo.close();
        
        log.finishOk();
    }
    
    function genImportsInner(fo:FileOutput, srcPath:String)
    {
        var serverImports = hant.findFiles(srcPath, isServerFile);
        var clientImports = hant.findFiles(srcPath, isClientFile);
        
        fo.writeString("#if php\n");
        fo.writeString(Lambda.map(serverImports, callback(file2import, srcPath)).join('\n'));
        fo.writeString("\n#else\n");
        fo.writeString(Lambda.map(clientImports, callback(file2import, srcPath)).join('\n'));
        fo.writeString("\n#end\n");
    }
    
    function isServerFile(path:String)
    {
        if (path == exeDir + "/tools") return false;
		
		if (FileSystem.isDirectory(path))
        {
            return !path.endsWith('.svn');
        }
        return path.endsWith('/Server.hx') || path.endsWith('/Bootstrap.hx');
    }
    
    function isClientFile(path:String)
    {
		if (path == exeDir + "/tools") return false;
		
        if (FileSystem.isDirectory(path))
        {
            return !path.endsWith('.svn');
        }
        return path.endsWith('/Client.hx');
    }
    
    function isSupportFile(path:String)
    {
		if (path == exeDir + "/tools"
		 || path == exeDir + "/run.n"
		 || path == exeDir + "/restorefiletime.exe"
		 || path == exeDir + "/readme.txt"
		 || path == exeDir + "/haxelib.xml"
		) return false;
		
		if (FileSystem.isDirectory(path))
		{
			return !path.endsWith(".svn");
		}
		return !path.endsWith(".hx") && !path.endsWith(".hxproj");
    }
    
	function isSupportFileWithoutComponents(path:String) : Bool
	{
		if (isSupportFile(path))
		{
			return path != exeDir + "/haquery/components";
		}
		return false;
	}
	
    function file2import(base:String, file:String) : String
    {
        if (file.startsWith(base))
        {
            file = file.substr(base.length + 1);
        }
        
        return "import " + Path.withoutExtension(file).replace('/', '.') + ';';
    }
    
    function isNotSvn(path:String)
    {
        if (FileSystem.isDirectory(path))
        {
            return !path.endsWith('.svn');
        }
        return true;
    }
    
    public function getClassPaths()
    {
        var r : Array<String> = new Array<String>();
        
		r.push(exeDir);
		
		for (file in FileSystem.readDirectory(''))
        {
            if (file.endsWith('.hxproj'))
            {
                var xml = Xml.parse(File.getContent(file));
                var fast = new haxe.xml.Fast(xml.firstElement());
                if (fast.hasNode.classpaths)
                {
                    var classpaths = fast.node.classpaths;
                    for (elem in classpaths.elements)
                    {
                        if (elem.name == 'class' && elem.has.path)
                        {
                            r.push(elem.att.path.replace('\\', '/'));
                        }
                    }
                }
            }
        }
        return r;
    }
	
	function getBinPath() : String
	{
		for (file in FileSystem.readDirectory(''))
		{
			if (file.endsWith(".hxproj"))
			{
				var xml = Xml.parse(File.getContent(file));
				var fast = new haxe.xml.Fast(xml.firstElement());
				if (fast.hasNode.output && fast.node.output.hasNode.movie)
				{
					var movie = fast.node.output.node.movie;
					if (movie.has.path)
					{
						return movie.att.path.replace('\\', '/');
					}
				}
			}
		}
		
		return "bin";
	}
	
    // -------------------------------------------------------------------------------
    
	function run(fileName:String, args:Array<String>)
	{
		try
		{
			var p : Process = new Process(fileName, args);
			//p.stdin.close();
			for (i in 1...100)
			{
				Sys.sleep(0.05);
			}
			Lib.println("PID(" + fileName + ") = " + p.getPid());
			if (p.getPid() != 0)
			{
				p.kill();
			}
		}
		catch (e:Dynamic)
		{
			Lib.println("Error: file '" + fileName + "' not found. Maybe you need to add directory to the PATH system environment variable.");
			throw e;
		}
	}
	
	function buildJs()
    {
        var binPath = getBinPath();
		
		log.start("Build client to '" + binPath + "/haquery/client/haquery.js'");
        
		if (FileSystem.exists(binPath + "/haquery/client/haquery.js"))
		{
			hant.rename(binPath + "/haquery/client/haquery.js", binPath + "/haquery/client/haquery.js.old");
		}
		
		hant.createDirectory(binPath + '/haquery/client');
        
        var params = new Array<String>();
        for (path in getClassPaths())
        {
            params.push('-cp'); params.push(path);
        }
		params.push("-lib"); params.push("HaQuery");
        params.push('-js');
        params.push(binPath + '/haquery/client/haquery.js');
        params.push('-main'); params.push('Main');
        params.push('-debug');
        run("haxe", params);
        
		if (FileSystem.exists(binPath + "/haquery/client/haquery.js")
		 && FileSystem.exists(binPath + "/haquery/client/haquery.js.old"))
		{
			restoreFileTime(binPath + "/haquery/client/haquery.js.old", binPath + "/haquery/client/haquery.js");
			hant.deleteFile(binPath + "/haquery/client/haquery.js.old");
		}
		
		log.finishOk();
    }
	
    public function genOrm(databaseConnectionString:String)
    {
        log.start("Generate object related mapping classes");
        
        Sys.command('php', [ exeDir + '/tools/orm/index.php', databaseConnectionString, 'src' ]);
        
        log.finishOk();
    }
    
    public function genTrm(componentsPackage:String)
    {
        log.start("Generate template related mapping classes");
        
        Sys.command('php', [ exeDir + '/tools/trm/index.php', componentsPackage ]);
        
        log.finishOk();
    }
    
	public function preBuild()
    {
        log.start("Do pre-build step");
        
        genImports();
		try { saveLibFolder(); } catch (e:Dynamic) { }
        
        log.finishOk();
    }
	
	function saveLibFolder()
	{
		var binPath = getBinPath();

		log.start("Save " + binPath + "/lib folder");

		if (FileSystem.exists(binPath + "/lib"))
		{
			hant.deleteDirectory(binPath + "/lib.old");
			hant.rename(binPath + "/lib", binPath + "/lib.old");
		}

		log.finishOk();
	}

	function loadLibFolder()
	{
		var binPath = getBinPath();
		
		log.start("Load file times to " + binPath + "/lib");

		if (FileSystem.exists(binPath + "/lib"))
		{
			restoreFileTime(binPath + "/lib.old", binPath + "/lib");
			hant.deleteDirectory(binPath + "/lib.old");
		}

		log.finishOk();
	}
	
    
    public function postBuild(skipJS:Bool, skipComponents:Bool)
    {
        log.start("Do post-build step");
        
		if (!skipJS)
		{
			buildJs();
		}
        
        for (path in getClassPaths())
        {
            hant.copyFolderContent(path, getBinPath(), !skipComponents ? isSupportFile : isSupportFileWithoutComponents);
        }
		
		loadLibFolder();
        
        log.finishOk();
    }
	
	function restoreFileTime(fromPath:String, toPath:String)
	{
		log.start("Restore file time '" + fromPath + "' => '" + toPath + "'");
		
		run(exeDir + "/restorefiletime.exe", [ fromPath.replace('/', '\\'), toPath.replace('/', '\\') ]);
		
		log.finishOk();
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
        
        var srcPath = exeDir + "/tools/flashdevelop.zip";
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
        
        var haxePath = getHaxePath();
        if (!FileSystem.exists(haxePath + 'std.original'))
        {
            hant.rename(haxePath + 'std', haxePath + 'std.original');
			
			var destPath = haxePath + "std";
			hant.createDirectory(destPath);
            unzip(exeDir + "/tools/haxemod.zip", destPath);
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
        
        
        var haxePath = getHaxePath();
        
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
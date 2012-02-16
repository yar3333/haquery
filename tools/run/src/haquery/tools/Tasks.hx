package haquery.tools;

import neko.io.File;
import neko.io.FileOutput;
import neko.io.Path;
import neko.Sys;
import neko.Lib;
import neko.FileSystem;
import neko.zip.Uncompress;

import haquery.server.db.HaqDb;
import haquery.tools.orm.OrmGenerator;
import haquery.tools.CompileStageComponentTemplateParser;

using StringTools;

class Tasks 
{
    var log : hant.Log;
    var hant : hant.Tasks;
	var exeDir : String;
    
    public function new(exeDir:String)
    {
        log = new hant.Log(2);
        hant = new hant.Tasks(log);
		this.exeDir = exeDir.replace('\\', '/');
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
        if (path == exeDir + "tools") return false;
		
		if (FileSystem.isDirectory(path))
        {
            return !path.endsWith('.svn');
        }
        return path.endsWith('/Server.hx') || path.endsWith('/Bootstrap.hx');
    }
    
    function isClientFile(path:String)
    {
		if (path == exeDir + "tools") return false;
		
        if (FileSystem.isDirectory(path))
        {
            return !path.endsWith('.svn');
        }
        return path.endsWith('/Client.hx');
    }
    
    function isSupportFile(path:String)
    {
		if (path == exeDir + "tools"
		 || path == exeDir + "run.n"
		 || path == exeDir + "restorefiletime.exe"
		 || path == exeDir + "readme.txt"
		 || path == exeDir + "haxelib.xml"
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
			return path != exeDir + "haquery/components";
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
    
	
	function buildJs()
    {
		var clientPath = getBinPath() + '/haquery/client';
		
		log.start("Build client to '" + clientPath + "/haquery.js'");
        
		if (FileSystem.exists(clientPath + "/haquery.js"))
		{
			hant.rename(clientPath + "/haquery.js", clientPath + "/haquery.js.old");
		}
		
		hant.createDirectory(clientPath);
        
        var params = new Array<String>();
        for (path in getClassPaths())
        {
            params.push('-cp'); params.push(path);
        }
		params.push("-lib"); params.push("HaQuery");
        params.push('-js');
        params.push(clientPath + "/haquery.js");
        params.push('-main'); params.push('Main');
        params.push('-debug');
        hant.run("haxe", params);
        
		if (FileSystem.exists(clientPath + "/haquery.js"))
		{
			var fapp = File.append(clientPath + "/haquery.js", false);
			fapp.writeString(getComponentEntendsCollectionsForInternalHtml());
			fapp.close();
		}
		
		if (FileSystem.exists(clientPath + "/haquery.js")
		 && FileSystem.exists(clientPath + "/haquery.js.old"))
		{
			restoreFileTime(clientPath + "/haquery.js.old", clientPath + "/haquery.js");
			hant.deleteFile(clientPath + "/haquery.js.old");
		}
		
		log.finishOk();
    }
	
	function getComponentEntendsCollectionsForInternalHtml() : String
	{
		var componentEntendsCollections = getComponentEntendsCollections();
		
		var s = "haquery.client.HaqInternals.componentEntendsCollections = haquery.HashTools.hashify({\n";
		
		s += Lambda.map(HashTools.keysIterable(componentEntendsCollections), function(collection)
		{
			var collectionTagExtends = componentEntendsCollections.get(collection);
			return collection + ": { " + Lambda.map(HashTools.keysIterable(collectionTagExtends), function(tag) return tag + ":" + "'" + collectionTagExtends.get(tag) + "'").join(", ") + " }";
		}).join(",\n");
		
		s += "});\n";
		
		return s;
	}
	
	/**
	 * @return collection -> tag -> extendsCollection
	 */
	function getComponentEntendsCollections() : Hash<Hash<String>>
	{
		var r = new Hash<Hash<String>>();
		
		for (classPath in getClassPaths())
		{
			for (collection in FileSystem.readDirectory(classPath))
			{
				var collectionPath = classPath + collection;
				if (FileSystem.exists(collectionPath) && FileSystem.isDirectory(collectionPath))
				{
					for (tag in FileSystem.readDirectory(collectionPath))
					{
						if (FileSystem.isDirectory(collectionPath + '/' + tag))
						{
							var parser = new CompileStageComponentTemplateParser(getClassPaths(), collection, tag);
							if (!r.exists(collection)) r.set(collection, new Hash<String>());
							r.get(collection).set(tag, parser.config.extendsCollection);
						}
					}
				}
			}
		}
		
		return r;
	}
	
    public function genOrm(databaseConnectionString:String, destBasePath:String)
    {
        log.start("Generate object related mapping classes");
        
		var re = new EReg('^([a-z]+)\\://([_a-zA-Z0-9]+)\\:(.+?)@([_a-zA-Z0-9]+)/([_a-zA-Z0-9]+)$', '');
		if (!re.match(databaseConnectionString))
		{
			Lib.println("Connection string example: 'mysql://root:123456@localhost/mydb'.");
			Sys.exit(1);
		}
		
		HaqDb.connect({
			 type : re.matched(1)
			,user : re.matched(2)
			,pass : re.matched(3)
			,host : re.matched(4)
			,database : re.matched(5)
		});
		
		OrmGenerator.make(destBasePath);
        
        log.finishOk();
    }
    
    function genTrm()
    {
        log.start("Generate template related mapping classes");
        
        haquery.tools.trm.TrmGenerator.run();
        
        log.finishOk();
    }
    
	public function preBuild()
    {
        log.start("Do pre-build step");
        
		genTrm();
		
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
		log.start("Restore file time '" + fromPath + "' => '" + toPath + "' (" + exeDir + ")");
		
		hant.run(exeDir + "restorefiletime.exe", [ fromPath.replace('/', '\\'), toPath.replace('/', '\\') ]);
		
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
        
        var haxePath = getHaxePath();
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
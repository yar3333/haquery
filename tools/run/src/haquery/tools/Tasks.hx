package haquery.tools;

import neko.io.File;
import neko.io.FileOutput;
import neko.io.Path;
import neko.Sys;
import neko.Lib;
import neko.FileSystem;
import neko.zip.Uncompress;

import haquery.server.db.HaqDb;
import haquery.server.HaqDefines;
import haquery.tools.orm.OrmGenerator;
import haquery.tools.trm.TrmGenerator;

using haquery.StringTools;

class Tasks 
{
	var exeDir : String;
    
	var log : Log;
    var hant : Hant;
	var project : FlashDevelopProject;
	var componentFileKind : ComponentFileKind;
    
    public function new(exeDir:String)
    {
		this.exeDir = exeDir.replace('\\', '/');
        
		log = new Log(2);
        hant = new Hant(log, this.exeDir);
		project = new FlashDevelopProject('.', this.exeDir);
		componentFileKind = new ComponentFileKind(this.exeDir);
    }
    
    function genImports()
    {
        log.start("Generate imports to 'src/Imports.hx'");
        
        var fo : FileOutput = File.write("src/Imports.hx", false);
        
        for (path in project.classPaths)
        {
            fo.writeString("// " + path + "\n");
			fo.writeString("#if php\n");
			fo.writeString(Lambda.map(hant.findFiles(path, componentFileKind.isServerFile), callback(file2import, path)).join('\n'));
			fo.writeString("\n#else\n");
			fo.writeString(Lambda.map(hant.findFiles(path, componentFileKind.isClientFile), callback(file2import, path)).join('\n'));
			fo.writeString("\n#end\n");
            fo.writeString("\n");
        }
        
        fo.close();
        
        log.finishOk();
    }
    
    function file2import(base:String, file:String) : String
    {
        if (file.startsWith(base))
        {
            file = file.substr(base.length + 1);
        }
        
        return "import " + Path.withoutExtension(file).replace('/', '.') + ';';
    }
	
	function buildJs()
    {
		var clientPath = project.binPath + '/haquery/client';
		
		log.start("Build client to '" + clientPath + "/haquery.js'");
        
		if (FileSystem.exists(clientPath + "/haquery.js"))
		{
			hant.rename(clientPath + "/haquery.js", clientPath + "/haquery.js.old");
		}
		
		hant.createDirectory(clientPath);
        
        var params = new Array<String>();
        for (path in project.classPaths)
        {
            params.push('-cp'); params.push(path);
        }
		params.push("-lib"); params.push("HaQuery");
        params.push('-js');
        params.push(clientPath + "/haquery.js");
        params.push('-main'); params.push('Main');
        params.push('-debug');
        params.push('-D'); params.push('noEmbedJS');
        hant.run("haxe", params);
        
		if (FileSystem.exists(clientPath + "/haquery.js")
		 && FileSystem.exists(clientPath + "/haquery.js.old"))
		{
			hant.restoreFileTime(clientPath + "/haquery.js.old", clientPath + "/haquery.js");
			hant.deleteFile(clientPath + "/haquery.js.old");
		}
		
		log.finishOk();
    }
	
	/*function getComponentEntendsCollectionsForInternalHtml() : String
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
	/*function getComponentEntendsCollections() : Hash<Hash<String>>
	{
		var r = new Hash<Hash<String>>();
		
		// TODO: collection findind
		for (classPath in project.classPaths)
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
							var parser = new HaqTemplateParser(project.classPaths, HaqDefines.folders.components + "." + collection + "." + tag);
							if (!r.exists(collection)) r.set(collection, new Hash<String>());
							r.get(collection).set(tag, parser.getExtend());
						}
					}
				}
			}
		}
		
		return r;
	}*/
	
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
		
		OrmGenerator.run(destBasePath);
        
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
	
    public function genTrm()
    {
        log.start("Generate template related mapping classes");
        
        TrmGenerator.run(project.classPaths);
        
        log.finishOk();
    }
	
	function saveLibFolder()
	{
		log.start("Save file times of the " + project.binPath + "/lib folder");

		if (FileSystem.exists(project.binPath + "/lib"))
		{
			hant.deleteDirectory(project.binPath + "/lib.old");
			hant.rename(project.binPath + "/lib", project.binPath + "/lib.old");
		}

		log.finishOk();
	}

	function loadLibFolder()
	{
		log.start("Load file times to " + project.binPath + "/lib");

		if (FileSystem.exists(project.binPath + "/lib"))
		{
			hant.restoreFileTime(project.binPath + "/lib.old", project.binPath + "/lib");
			hant.deleteDirectory(project.binPath + "/lib.old");
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
        
        for (path in project.classPaths)
        {
            hant.copyFolderContent(path, project.binPath, !skipComponents ? componentFileKind.isSupportFile : componentFileKind.isSupportFileWithoutComponents);
        }
		
		loadLibFolder();
        
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
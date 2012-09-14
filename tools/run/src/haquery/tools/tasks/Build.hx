package haquery.tools.tasks;

import sys.io.File;
import haxe.io.Path;

import haquery.common.HaqDefines;
import haquery.server.FileSystem;
import haquery.tools.Excludes;
import haquery.tools.HaqTemplateManager;
import haquery.tools.JSMin;
import haquery.tools.PackageTree;
import haquery.tools.FlashDevelopProject;
import haquery.tools.trm.TrmGenerator;

import haquery.base.HaqTemplateParser.HaqTemplateNotFoundException;
import haquery.base.HaqTemplateParser.HaqTemplateRecursiveExtendException;

using haquery.StringTools;
using haquery.HashTools;

class Build 
{
	var exeDir : String;
    
	var log : Log;
    var hant : Hant;
	var project : FlashDevelopProject;

	public function new(exeDir:String) 
	{
		this.exeDir = exeDir.replace('\\', '/').rtrim('/') + '/';
        
		log = new Log(2);
        hant = new Hant(log, this.exeDir);
		project = new FlashDevelopProject('.', this.exeDir);
	}
	
	public function preBuild()
    {
        log.start("Do pre-build step");
        
		try
		{
			var manager = new HaqTemplateManager(project.allClassPaths, log);
			genTrm(manager);
			genImports(manager, project.srcPath);
			if (genShared(project))
			{
				saveLastMods(manager);
				try { saveLibFolder(); } catch (e:Dynamic) { }
				log.finishOk();
				return true;
			}
		}
		catch (e:HaqTemplateNotFoundException)
		{
			log.finishFail("ERROR: component not found [ " + e.toString() + " ].");
		}
		catch (e:HaqTemplateRecursiveExtendException)
		{
			log.finishFail("ERROR: recursive extend detected [ " + e.toString() + " ].");
		}
		return false;
    }
	
    public function postBuild() : Bool
    {
        log.start("Do post-build step");
        
		if (!buildJs())
		{
			return false;
		}
        
        var excludes = new Excludes(project.libPaths);
		for (path in project.libPaths)
		{
			if (FileSystem.exists(path + "excludes.xml"))
			{
				excludes.appendFromFile(path + "excludes.xml");
			}
		}
		
		var manager = new HaqTemplateManager(project.allClassPaths, log);
		var reUnusedTemplate = new PackageTree(manager.unusedTemplates).toString();
		for (path in project.allClassPaths)
		{
			var reExclude = "(?:" + excludes.getRegExp(path) + ")|(?:" + (path + reUnusedTemplate).replace(".", "[.]") + ")";
			hant.copyFolderContent(path, project.binPath, project.platform, "^(?:" + reExclude + ")$");
		}
		
		loadLibFolder();
        
        log.finishOk();
		
		return true;
    }
    
	function genImports(manager:HaqTemplateManager, srcPath:String)
    {
        log.start("Generate imports to '" + srcPath + "Imports.hx'");
        
        var fo = File.write(srcPath + "Imports.hx", false);
        
        var serverClassNames = new Hash<Int>();
        var clientClassNames = new Hash<Int>();
		for (fullTag in manager.getLastMods().keys())
		{
			if (!Lambda.has(manager.unusedTemplates, fullTag))
			{
				serverClassNames.set(manager.get(fullTag).serverClassName, 1);
				clientClassNames.set(manager.get(fullTag).clientClassName, 1);
			}
		}
		
		var arrServerClassNames = Lambda.array(serverClassNames.keysIterable());
		arrServerClassNames.sort(strcmp);
		
		var arrClientClassNames = Lambda.array(clientClassNames.keysIterable());
		arrClientClassNames.sort(strcmp);
		
		fo.writeString("#if !client\n\n");
		fo.writeString(Lambda.map(findBootstrapClassNames(HaqDefines.folders.pages, srcPath), function(s) return "import " + s + ";").join('\n'));
		fo.writeString("\n");
		fo.writeString("\n");
		fo.writeString(Lambda.map(arrServerClassNames, function(s) return "import " + s + ";").join('\n'));
		fo.writeString("\n\n#else\n\n");
		fo.writeString(Lambda.map(arrClientClassNames, function(s) return "import " + s + ";").join('\n'));
		fo.writeString("\n\n#end\n");
        
        fo.close();
        
        log.finishOk();
    }
    
    function strcmp(a:String, b:String) : Int
    {
        if (a == b) return 0;
		return a < b ? -1 : 1;
    }
	
	function findBootstrapClassNames(path:String, srcPath:String) : List<String>
	{
		var files = hant.findFiles(srcPath + path, function(s) return s.endsWith("/Bootstrap.hx"));
		return Lambda.map(files, function(s) return s.substr(srcPath.length, s.length - srcPath.length - ".hx".length).replace("/", "."));
	}
	
	function buildJs() : Bool
    {
		var clientPath = project.binPath + '/haquery/client';
		
		log.start("Build client to '" + clientPath + "/haquery.js'");
        
		if (FileSystem.exists(clientPath + "/haquery.js"))
		{
			hant.rename(clientPath + "/haquery.js", clientPath + "/haquery.js.old");
		}
		
		hant.createDirectory(clientPath);
        
        var params = project.getBuildParams("-js", clientPath + "/haquery.js", [ "noEmbedJS", "client" ]);
		var r = hant.runWaiter(hant.getHaxePath() + "haxe.exe", params, 10000);
        
		if (FileSystem.exists(clientPath + "/haquery.js")
		 && FileSystem.exists(clientPath + "/haquery.js.old"))
		{
			hant.restoreFileTime(clientPath + "/haquery.js.old", clientPath + "/haquery.js");
			hant.deleteFile(clientPath + "/haquery.js.old");
		}
		
		if (r == 0)
		{
			if (!project.isDebug)
			{
				File.saveContent(clientPath + "/haquery.js", new JSMin(File.getContent(clientPath + "/haquery.js")).output);
			}
			
			log.finishOk();
		}
		else
		{
			try { log.finishFail("Post-build interrupted because client compile errors."); }
			catch (e:Dynamic) {}
		}
		
		return r == 0;
    }
	
	function saveLastMods(manager:HaqTemplateManager)
	{
		var serverPath = project.binPath + '/haquery/server';
		hant.createDirectory(serverPath);
		
		var lastMods = manager.getLastMods();
		File.saveContent(
			 serverPath + "/templates.dat"
			,Lambda.map(
				 Lambda.filter(lastMods.keysIterable(), function(fullTag) return !Lambda.has(manager.unusedTemplates, fullTag))
				,function(fullTag) return fullTag + "\t" + Math.round(lastMods.get(fullTag).getTime() / 10000.0)
			 ).join("\n")
		);
	}
	
    public function genTrm(?manager:HaqTemplateManager)
    {
        log.start("Generate template related mapping classes");
        
        TrmGenerator.run(manager!=null ? manager : new HaqTemplateManager(project.allClassPaths, log), hant);
        
        log.finishOk();
    }
	
	function genShared(project:FlashDevelopProject) : Bool
	{
        var tempPath = "trm/temp-haquery-gen-shared.js";
		
		log.start("Generate shared classes from client");
		hant.createDirectory(Path.directory(tempPath));
		var params = project.getBuildParams("-js", tempPath, [ "noEmbedJS", "client" ]);
		var r = hant.runWaiter(hant.getHaxePath() + "haxe.exe", params, 10000);
		hant.deleteFile(tempPath);
		hant.deleteFile(tempPath + ".map");
		if (r != 0) return false;
        log.finishOk();
		
		return true;
	}
	
	function saveLibFolder()
	{
		if (FileSystem.exists(project.binPath + "/lib"))
		{
			log.start("Save file times of the " + project.binPath + "/lib folder");
			loadLibFolder();
			hant.rename(project.binPath + "/lib", project.binPath + "/lib.old");
			log.finishOk();
		}
	}

	function loadLibFolder()
	{
		if (FileSystem.exists(project.binPath + "/lib.old"))
		{
			log.start("Load file times to " + project.binPath + "/lib");
			hant.restoreFileTime(project.binPath + "/lib.old", project.binPath + "/lib");
			hant.deleteDirectory(project.binPath + "/lib.old");
			log.finishOk();
		}
	}
}
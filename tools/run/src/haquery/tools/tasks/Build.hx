package haquery.tools.tasks;

import haquery.tools.Publisher;
import neko.Lib;
import sys.io.File;
import haxe.io.Path;
import haquery.common.HaqDefines;
import haquery.server.FileSystem;
import haquery.tools.HaqTemplateManager;
import haquery.tools.JSMin;
import haquery.tools.FlashDevelopProject;
import haquery.tools.trm.TrmGenerator;
import haquery.base.HaqTemplateParser.HaqTemplateNotFoundException;
import haquery.base.HaqTemplateParser.HaqTemplateRecursiveExtendException;
using haquery.StringTools;

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
	
	public function preBuild(noGenCode:Bool, isJsModern:Bool, isDeadCodeElimination:Bool)
    {
        log.start("Do pre-build step");
        
		try
		{
			var manager = new HaqTemplateManager(project.allClassPaths, log);
			genTrm(manager);
			genImports(manager, project.srcPath);
			if (noGenCode || (genCodeFromClient(project) && genCodeFromServer(project)))
			{
				try { saveLibFolderFileTimes(); } catch (e:Dynamic) { }
				if (buildJs(isJsModern, isDeadCodeElimination))
				{
					saveTemplatesLastMods(manager);
					log.finishOk();
					return true;
				}
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
			
			log.start("Prepare");
				var manager = new HaqTemplateManager(project.allClassPaths, log);
				var publisher = new Publisher(exeDir, project.platform);
				for (path in project.allClassPaths)
				{
					publisher.prepare(path, manager.fullTags);
				}
			log.finishOk();
			
			log.start("Publish");
				publisher.publish(project.binPath);
			log.finishOk();
			
			loadLibFolderFileTimes();
        
        log.finishOk();
		
		return true;
    }
    
	function genImports(manager:HaqTemplateManager, src:String)
    {
        log.start("Generate imports to 'gen/Imports.hx'");
        
        hant.createDirectory("gen");
		var fo = File.write("gen/Imports.hx", false);
        
        var serverClassNames = new Hash<Int>();
        var clientClassNames = new Hash<Int>();
		for (fullTag in manager.getLastMods().keys())
		{
			serverClassNames.set(manager.get(fullTag).serverClassName, 1);
			clientClassNames.set(manager.get(fullTag).clientClassName, 1);
		}
		
		var arrServerClassNames = Lambda.array({ iterator:serverClassNames.keys });
		arrServerClassNames.sort(strcmp);
		
		var arrClientClassNames = Lambda.array({ iterator:clientClassNames.keys });
		arrClientClassNames.sort(strcmp);
		
		fo.writeString("#if !client\n\n");
		fo.writeString(Lambda.map(findBootstrapClassNames(src, HaqDefines.folders.pages), function(s) return "import " + s + ";").join('\n'));
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
	
	function findBootstrapClassNames(basePath:String, relPath:String) : Array<String>
	{
		var r = [];
		hant.findFiles(basePath + relPath, function(path)
		{
			if (path.endsWith("/Bootstrap.hx"))
			{
				r.push(path.substr(basePath.length, path.length - basePath.length - ".hx".length).replace("/", "."));
			}
		});
		return r;
	}
	
	function buildJs(isJsModern:Bool, isDeadCodeElimination:Bool) : Bool
    {
		var clientPath = project.binPath + '/haquery/client';
		
		log.start("Build client to '" + clientPath + "/haquery.js'");
        
		if (FileSystem.exists(clientPath + "/haquery.js"))
		{
			hant.rename(clientPath + "/haquery.js", clientPath + "/haquery.js.old");
		}
		
		hant.createDirectory(clientPath);
        
        var params = project.getBuildParams("js", clientPath + "/haquery.js", [ "noEmbedJS", "client" ]);
		if (isJsModern) params.push("--js-modern");
		if (isDeadCodeElimination) params.push("--dead-code-elimination");
		var r = hant.run(hant.getHaxePath() + "haxe.exe", params);
		Lib.print(r.stdOut);
		Lib.print(r.stdErr);
        
		if (FileSystem.exists(clientPath + "/haquery.js")
		 && FileSystem.exists(clientPath + "/haquery.js.old"))
		{
			hant.restoreFileTimes(clientPath + "/haquery.js.old", clientPath + "/haquery.js");
			hant.deleteFile(clientPath + "/haquery.js.old");
		}
		
		if (r.exitCode == 0)
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
		
		return r.exitCode == 0;
    }
	
	function saveTemplatesLastMods(manager:HaqTemplateManager)
	{
		var serverPath = project.binPath + '/haquery/server';
		hant.createDirectory(serverPath);
		
		var lastMods = manager.getLastMods();
		File.saveContent(
			 serverPath + "/templates.dat"
			,Lambda.map(
				  { iterator:lastMods.keys }
				, function(fullTag) return fullTag + "\t" + Math.round(lastMods.get(fullTag).getTime() / 10000.0)
			 ).join("\n")
		);
	}
	
    public function genTrm(?manager:HaqTemplateManager)
    {
        log.start("Generate template related mapping classes");
        
        TrmGenerator.run(manager!=null ? manager : new HaqTemplateManager(project.allClassPaths, log), hant);
        
        log.finishOk();
    }
	
	function genCodeFromClient(project:FlashDevelopProject) : Bool
	{
        var tempPath = "gen/temp-haquery-gen-code.js";
		
		log.start("Generate code from client");
		hant.createDirectory(Path.directory(tempPath));
		var params = project.getBuildParams("js", tempPath, [ "noEmbedJS", "client", "haqueryGenCode" ]);
		var r = hant.run(hant.getHaxePath() + "haxe.exe", params);
		hant.deleteFile(tempPath);
		hant.deleteFile(tempPath + ".map");
		Lib.print(r.stdOut);
		Lib.print(r.stdErr);
		if (r.exitCode != 0) return false;
        log.finishOk();
		
		return true;
	}
	
	function genCodeFromServer(project:FlashDevelopProject) : Bool
	{
        var tempPath = "gen/temp-haquery-gen-code.n";
		
		log.start("Generate code from server");
		hant.createDirectory(Path.directory(tempPath));
		var params = project.getBuildParams(project.platform.toLowerCase(), tempPath, [ "haqueryGenCode" ]);
		var r = hant.run(hant.getHaxePath() + "haxe.exe", params);
		hant.deleteFile(tempPath);
		Lib.print(r.stdOut);
		Lib.print(r.stdErr);
		if (r.exitCode != 0) return false;
        log.finishOk();
		
		return true;
	}
	
	function saveLibFolderFileTimes()
	{
		if (FileSystem.exists(project.binPath + "/lib"))
		{
			log.start("Save file times of the " + project.binPath + "/lib folder");
			loadLibFolderFileTimes();
			hant.rename(project.binPath + "/lib", project.binPath + "/lib.old");
			log.finishOk();
		}
	}

	function loadLibFolderFileTimes()
	{
		if (FileSystem.exists(project.binPath + "/lib.old"))
		{
			log.start("Load lib folder file times");
			hant.restoreFileTimes(project.binPath + "/lib.old", project.binPath + "/lib", ~/[.](?:php|js)/i);
			hant.deleteDirectory(project.binPath + "/lib.old");
			log.finishOk();
		}
	}
	
	public function genCode() : Bool
	{
        log.start("Generate shared and another methods");
		
		try
		{
			var manager = new HaqTemplateManager(project.allClassPaths, log);
			genTrm(manager);
			genImports(manager, project.srcPath);
			var r = genCodeFromClient(project) && genCodeFromServer(project);
			if (r)
			{
				log.finishOk();
			}
			else
			{
				try { log.finishFail("ERROR: compilation."); }
				catch (e:Dynamic) {}
			}
			return r;
		}
		catch (e:HaqTemplateNotFoundException)
		{
			log.finishFail("ERROR: component not found [ " + e.toString() + " ].");
			return false;
		}
		catch (e:HaqTemplateRecursiveExtendException)
		{
			log.finishFail("ERROR: recursive extend detected [ " + e.toString() + " ].");
			return false;
		}
	}
}
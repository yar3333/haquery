package ;

import hant.Log;
import hant.Hant;
import hant.PathTools;
import hant.Process;
import haxe.Serializer;
import neko.Lib;
import sys.io.File;
import haxe.io.Path;
import haquery.common.HaqDefines;
import haquery.server.FileSystem;
using haquery.StringTools;

class Build 
{
	var log : Log;
    var hant : Hant;
	var exeDir : String;
    
	var project : FlashDevelopProject;

	public function new(log:Log, hant:Hant, exeDir:String) 
	{
		this.log = log;
		this.hant = hant;
		this.exeDir = PathTools.path2normal(exeDir) + "/";
		project = new FlashDevelopProject("");
	}
	
	public function preBuild(noGenCode:Bool, isJsModern:Bool, isDeadCodeElimination:Bool)
    {
        log.start("Do pre-build step");
        
		try
		{
			var manager = new HaqTemplateManager(log, project.allClassPaths);
			
			genTrm(manager);
			generateConfigClasses(manager);
			genImports(manager, project.srcPath);
			
			if (noGenCode || (genCodeFromClient(project) && genCodeFromServer(project)))
			{
				try { saveLibFolderFileTimes(); } catch (e:Dynamic) { }
				if (buildJs(isJsModern, isDeadCodeElimination))
				{
					log.finishOk();
					return true;
				}
			}
		}
		catch (e:haquery.Exception)
		{
			log.finishFail();
			throw e;
		}
		
		return false;
    }
	
    public function postBuild() : Bool
    {
        log.start("Do post-build step");
			
			var manager = new HaqTemplateManager(log, project.allClassPaths);
			
			log.start("Generate style file");
				generateComponentsCssFile(manager, project.binPath);
			log.finishOk();
			
			var publisher = new Publisher(log, hant, project.platform);
			
			log.start("Publish");
				for (path in project.allClassPaths)
				{
					publisher.prepare(path, manager.fullTags);
				}
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
		
		fo.writeString("#if !client\n\n");
		fo.writeString(Lambda.map(findBootstrapClassNames(src, HaqDefines.folders.pages), function(s) return "import " + s + ";").join('\n'));
		fo.writeString("\n");
		fo.writeString("\n");
		fo.writeString(Lambda.map(manager.fullTags, function(s) return "import " + s + ".ConfigServer;").join('\n'));
		fo.writeString("\n\n#else\n\n");
		fo.writeString(Lambda.map(manager.fullTags, function(s) return "import " + s + ".ConfigClient;").join('\n'));
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
		var r = Process.run(hant.getHaxePath() + "haxe.exe", params);
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
			log.finishFail();
		}
		
		return r.exitCode == 0;
    }
	
    public function genTrm(?manager:HaqTemplateManager)
    {
        log.start("Generate template related mapping classes");
        
        TrmGenerator.run(manager != null ? manager : new HaqTemplateManager(log, project.allClassPaths), hant);
        
        log.finishOk();
    }
	
	function genCodeFromClient(project:FlashDevelopProject) : Bool
	{
        var tempPath = "gen/temp-haquery-gen-code.js";
		
		log.start("Generate code from client");
		hant.createDirectory(Path.directory(tempPath));
		var params = project.getBuildParams("js", tempPath, [ "noEmbedJS", "client", "haqueryGenCode" ]);
		var r = Process.run(hant.getHaxePath() + "haxe.exe", params);
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
		var r = Process.run(hant.getHaxePath() + "haxe.exe", params);
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
			var manager = new HaqTemplateManager(log, project.allClassPaths);
			
			genTrm(manager);
			generateConfigClasses(manager);
			genImports(manager, project.srcPath);

			var r = genCodeFromClient(project) && genCodeFromServer(project);
			if (r)
			{
				log.finishOk();
			}
			else
			{
				log.finishFail();
			}
			return r;
		}
		catch (e:Dynamic)
		{
			log.finishFail();
			throw e;
		}
	}
	
	function generateConfigClasses(manager:HaqTemplateManager)
	{
		log.start("Generate config classes");
		
		for (fullTag in manager.fullTags)
		{
			var template = manager.get(fullTag);
			var dir = "gen/" + fullTag.replace(".", "/");
			FileSystem.createDirectory(dir);
			File.saveContent(dir + "/ConfigServer.hx"
				, "// This is autogenerated file. Do not edit!\n\n"
				+ "package " + fullTag + ";\n\n"
				+ "import " + template.serverClassName + ";\n\n"
				+ "@:keep class ConfigServer\n"
				+ "{\n"
				+ "\tpublic static var extend = '" + template.extend + "';\n"
				+ "\tpublic static var serverClassName = '" + template.serverClassName + "';\n"
				+ "\tpublic static var serializedDoc = '" + Serializer.run(template.doc) + "';\n"
				+ "}\n"
				
				+ "\n/*\n"
				+ template.doc.innerHTML
				+ "*/\n"
			);
			
			File.saveContent(dir + "/ConfigClient.hx"
				, "// This is autogenerated file. Do not edit!\n\n"
				+ "package " + fullTag + ";\n\n"
				+ "import " + template.clientClassName + ";\n\n"
				+ "@:keep class ConfigClient\n"
				+ "{\n"
				+ "\tpublic static var clientClassName = '" + template.clientClassName + "';\n"
				+ "\t// SERVER_HANDLERS\n"
				+ "}\n"
			);
		}
		
		log.finishOk();
	}
	
	function generateComponentsCssFile(manager:HaqTemplateManager, binDir:String)
	{
		var dir = binDir + "/haquery/client";
		FileSystem.createDirectory(dir);
		
		var text = "";
		for (fullTag in manager.fullTags)
		{
			var template = manager.get(fullTag);
			if (template.css.length > 0)
			{
				text += "/" + "* " + fullTag + "*" + "/\n" + template.css + "\n\n";
			}
		}
		
		File.saveContent(dir + "/haquery.css", text);
	}
}
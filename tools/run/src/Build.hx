package ;

import hant.Log;
import hant.FileSystemTools;
import hant.PathTools;
import hant.Process;
import haquery.Exception;
import haxe.Serializer;
import neko.Lib;
import sys.io.File;
import haxe.io.Path;
import haquery.common.HaqDefines;
import haquery.server.FileSystem;
using haquery.StringTools;

class CompilationFailException extends Exception
{
	override public function toString() return message
}

class Build 
{
	var log : Log;
    var fs : FileSystemTools;
	var exeDir : String;
    
	var project : FlashDevelopProject;

	public function new(log:Log, fs:FileSystemTools, exeDir:String) 
	{
		this.log = log;
		this.fs = fs;
		this.exeDir = PathTools.path2normal(exeDir) + "/";
		project = new FlashDevelopProject(log, "");
	}
	
	public function build(outputDir:String, noGenCode:Bool, jsModern:Bool, isDeadCodeElimination:Bool)
    {
        log.start("Build");
        
		try
		{
			var manager = new HaqTemplateManager(log, project.allClassPaths);
			
			genTrm(manager);
			generateConfigClasses(manager);
			genImports(manager, project.srcPath);
			
			if (!noGenCode)
			{
				genCodeFromClient(project);
				genCodeFromServer(project);
			}
			
			try { saveLibFolderFileTimes(outputDir); } catch (e:Dynamic) { }
			
			buildServer(outputDir);
			buildClient(outputDir, jsModern, isDeadCodeElimination);
			
			log.start("Generate style file");
				generateComponentsCssFile(manager, outputDir);
			log.finishOk();
			
			var publisher = new Publisher(log, fs, project.platform);
			
			log.start("Publish to '" + outputDir + "'");
				for (path in project.allClassPaths)
				{
					publisher.prepare(path, manager.fullTags);
				}
				publisher.publish(outputDir);
			log.finishOk();
			
			loadLibFolderFileTimes(outputDir);
			
			log.finishOk();
		}
		catch (e:Dynamic)
		{
			log.finishFail(e);
		}
    }
    
	function genImports(manager:HaqTemplateManager, src:String)
    {
        log.start("Generate imports");
        
        fs.createDirectory("gen");
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
		fs.findFiles(basePath + relPath, function(path)
		{
			if (path.endsWith("/Bootstrap.hx"))
			{
				r.push(path.substr(basePath.length, path.length - basePath.length - ".hx".length).replace("/", "."));
			}
		});
		return r;
	}
	
	function buildClient(outputDir:String, isJsModern:Bool, isDeadCodeElimination:Bool)
    {
		var clientPath = outputDir + '/haquery/client';
		
		log.start("Build client to '" + clientPath + "/haquery.js'");
        
		if (FileSystem.exists(clientPath + "/haquery.js"))
		{
			fs.rename(clientPath + "/haquery.js", clientPath + "/haquery.js.old");
		}
		
		fs.createDirectory(clientPath);
        
        var params = project.getBuildParams("js", clientPath + "/haquery.js", [ "noEmbedJS", "client" ]);
		if (isJsModern) params.push("--js-modern");
		if (isDeadCodeElimination) params.push("--dead-code-elimination");
		var r = Process.run(log, fs.getHaxePath() + "haxe.exe", params);
		Lib.print(r.stdOut);
		Lib.print(r.stdErr);
        
		if (FileSystem.exists(clientPath + "/haquery.js")
		 && FileSystem.exists(clientPath + "/haquery.js.old"))
		{
			fs.restoreFileTimes(clientPath + "/haquery.js.old", clientPath + "/haquery.js");
			fs.deleteFile(clientPath + "/haquery.js.old");
		}
		
		fs.deleteFile(clientPath + "/haquery.js.map");
		
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
			log.finishFail("Client compilation errors.");
		}
    }
	
	function buildServer(outputDir:String)
	{
		log.start("Build server to '" + outputDir + "'");
        var params = project.getBuildParams(project.platform, project.platform != "neko" ? outputDir : outputDir + "/index.n", [ "server" ]);
		var r = Process.run(log, fs.getHaxePath() + "haxe.exe", params);
		Lib.print(r.stdOut);
		Lib.print(r.stdErr);
		
		if (r.exitCode == 0)
		{
			log.finishOk();
		}
		else
		{
			log.finishFail("Server compilation errors.");
		}
	}
	
    public function genTrm(?manager:HaqTemplateManager)
    {
        log.start("Generate template classes");
        
        TrmGenerator.run(manager != null ? manager : new HaqTemplateManager(log, project.allClassPaths), fs);
        
        log.finishOk();
    }
	
	function genCodeFromClient(project:FlashDevelopProject)
	{
        var tempPath = "gen/temp-haquery-gen-code.js";
		
		log.start("Generate code from client");
		fs.createDirectory(Path.directory(tempPath));
		var params = project.getBuildParams("js", tempPath, [ "noEmbedJS", "client", "haqueryGenCode" ]);
		var r = Process.run(log, fs.getHaxePath() + "haxe.exe", params);
		fs.deleteFile(tempPath);
		fs.deleteFile(tempPath + ".map");
		Lib.print(r.stdOut);
		Lib.print(r.stdErr);
		if (r.exitCode == 0) log.finishOk();
		else                 log.finishFail(new CompilationFailException("Client compilation errors."));
	}
	
	function genCodeFromServer(project:FlashDevelopProject)
	{
        var tempPath = project.platform == "neko" ?  "gen/temp-haquery-gen-code.n" : "gen/temp-haquery-gen-code";
		
		log.start("Generate code from server");
		fs.createDirectory(project.platform == "neko" ? Path.directory(tempPath) : tempPath);
		var params = project.getBuildParams(project.platform, tempPath, [ "server", "haqueryGenCode" ]);
		var r = Process.run(log, fs.getHaxePath() + "haxe.exe", params);
		fs.deleteAny(tempPath);
		if (r.stdOut.trim() != "") Lib.print(r.stdOut);
		if (r.stdErr.trim() != "") Lib.print(r.stdErr);
		if (r.exitCode == 0) log.finishOk();
		else                 log.finishFail(new CompilationFailException("Server compilation errors."));
	}
	
	function saveLibFolderFileTimes(outputDir:String)
	{
		if (FileSystem.exists(outputDir + "/lib"))
		{
			log.start("Save file times of the " + outputDir + "/lib folder");
			loadLibFolderFileTimes(outputDir);
			fs.rename(outputDir + "/lib", outputDir + "/lib.old");
			log.finishOk();
		}
	}

	function loadLibFolderFileTimes(outputDir:String)
	{
		if (FileSystem.exists(outputDir + "/lib.old"))
		{
			log.start("Load lib folder file times");
			fs.restoreFileTimes(outputDir + "/lib.old", outputDir + "/lib", ~/[.](?:php|js)/i);
			fs.deleteDirectory(outputDir + "/lib.old");
			log.finishOk();
		}
	}
	
	public function genCode()
	{
        log.start("Generate shared and another methods");
		
		try
		{
			var manager = new HaqTemplateManager(log, project.allClassPaths);
			
			genTrm(manager);
			generateConfigClasses(manager);
			genImports(manager, project.srcPath);

			genCodeFromServer(project);
			genCodeFromClient(project);
			
			log.finishOk();
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
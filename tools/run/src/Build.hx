package ;

import hant.Log;
import hant.FileSystemTools;
import hant.PathTools;
import hant.Process;
import haquery.Exception;
import haxe.htmlparser.HtmlNodeElement;
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
	
	public function build(outputDir:String, noGenCode:Bool, jsModern:Bool, isDeadCodeElimination:Bool, noServer:Bool, noClient:Bool, mobile:Bool)
    {
        log.start("Build");
        
		try
		{
			var manager = new HaqTemplateManager(log, project.allClassPaths);
			
			genTrm(manager);
			generateConfigClasses(manager, noServer, noClient);
			generateImports(manager, project.srcPath);
			generateManagers(project);
			
			if (!noGenCode)
			{
				if (!noClient) genCodeFromClient(project, mobile);
				if (!noServer) genCodeFromServer(project, mobile);
			}
			
			try { saveLibFolderFileTimes(outputDir); } catch (e:Dynamic) {}
			
			if (!noServer) buildServer(outputDir, mobile);
			if (!noClient) buildClient(outputDir, jsModern, isDeadCodeElimination, mobile);
			
			generateComponentsCssFile(manager, outputDir);
			
			if (mobile)
			{
				generateMobilePages(manager, outputDir);
			}
			
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
    
	function generateImports(manager:HaqTemplateManager, src:String)
    {
        log.start("Generate imports");
        
        fs.createDirectory("gen");
		
		var fo = File.write("gen/Imports.hx", false);
		fo.writeString("#if server\n\n");
		fo.writeString(Lambda.map(findBootstrapClassNames(src, HaqDefines.folders.pages), function(s) return "import " + s + ";").join('\n'));
		fo.writeString("\n");
		fo.writeString("\n");
		fo.writeString(Lambda.map(manager.fullTags, function(s) return "import " + s + ".ConfigServer;").join('\n'));
		fo.writeString("\n\n#elseif client\n\n");
		fo.writeString(Lambda.map(manager.fullTags, function(s) return "import " + s + ".ConfigClient;").join('\n'));
		fo.writeString("\n\n#end\n");
        fo.close();
        
        log.finishOk();
    }
	
	function generateManagers(project:FlashDevelopProject)
	{
        /*
		log.start("Generate managers");
        
        fs.createDirectory("gen/autogenerated/haquery");
		
		var fo = File.write("gen/autogenerated/haquery/ManagersServer.hx", false);
		fo.writeString("package autogenerated.haquery;\n\n");
		fo.writeString("class ManagersServer\n");
		fo.writeString("{\n");
		
		var classes = new Array<{  }>();
		for (classPath in project.allClassPaths)
		{
			var path = path + "/managers/server";
			fs.findFiles(path, function(file)
			{
				if (file.endsWith("Manager.hx"))
				{
					classes.push("managers.server");
				}
			});
		}
		
		fo.writeString(Lambda.map(findBootstrapClassNames(src, HaqDefines.folders.pages), function(s) return "import " + s + ";").join('\n'));
		fo.writeString("\n");
		fo.writeString("\n");
		fo.writeString(Lambda.map(manager.fullTags, function(s) return "import " + s + ".ConfigServer;").join('\n'));
		fo.writeString("}\n");
        fo.close();
        
        log.finishOk();
		*/
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
	
	function buildClient(outputDir:String, isJsModern:Bool, isDeadCodeElimination:Bool, mobile:Bool)
    {
		var clientPath = outputDir + '/haquery/client';
		
		log.start("Build client to '" + clientPath + "/haquery.js'");
        
		if (FileSystem.exists(clientPath + "/haquery.js"))
		{
			fs.rename(clientPath + "/haquery.js", clientPath + "/haquery.js.old");
		}
		
		fs.createDirectory(clientPath);
        
        var params = project.getBuildParams("js", clientPath + "/haquery.js", [ "noEmbedJS", "client", mobile ? "mobile" : null ]);
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
	
	function buildServer(outputDir:String, mobile:Bool)
	{
		log.start("Build server to '" + outputDir + "'");
        var params = project.getBuildParams(project.platform, project.platform != "neko" ? outputDir : outputDir + "/index.n", [ "server", mobile ? "mobile" : null ]);
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
	
	function genCodeFromClient(project:FlashDevelopProject, mobile:Bool)
	{
        var tempPath = "gen/temp-haquery-gen-code.js";
		
		log.start("Generate code from client");
		fs.createDirectory(Path.directory(tempPath));
		var params = project.getBuildParams("js", tempPath, [ "noEmbedJS", "client", "haqueryGenCode", mobile ? "mobile" : null ]);
		var r = Process.run(log, fs.getHaxePath() + "haxe.exe", params);
		fs.deleteFile(tempPath);
		fs.deleteFile(tempPath + ".map");
		Lib.print(r.stdOut);
		Lib.print(r.stdErr);
		if (r.exitCode == 0) log.finishOk();
		else                 log.finishFail(new CompilationFailException("Client compilation errors."));
	}
	
	function genCodeFromServer(project:FlashDevelopProject, mobile:Bool)
	{
        var tempPath = project.platform == "neko" ?  "gen/temp-haquery-gen-code.n" : "gen/temp-haquery-gen-code";
		
		log.start("Generate code from server");
		fs.createDirectory(project.platform == "neko" ? Path.directory(tempPath) : tempPath);
		var params = project.getBuildParams(project.platform, tempPath, [ "server", "haqueryGenCode", mobile ? "mobile" : null ]);
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
	
	public function genCode(mobile:Bool)
	{
        log.start("Generate shared and another methods");
		
		try
		{
			var manager = new HaqTemplateManager(log, project.allClassPaths);
			
			genTrm(manager);
			generateConfigClasses(manager, false, false);
			generateImports(manager, project.srcPath);
			generateManagers(project);
			
			genCodeFromServer(project, mobile);
			genCodeFromClient(project, mobile);
			
			log.finishOk();
		}
		catch (e:Dynamic)
		{
			log.finishFail();
			throw e;
		}
	}
	
	function generateConfigClasses(manager:HaqTemplateManager, noServer:Bool, noClient:Bool)
	{
		log.start("Generate config classes");
		
		for (fullTag in manager.fullTags)
		{
			var template = manager.get(fullTag);
			var dir = "gen/" + fullTag.replace(".", "/");
			FileSystem.createDirectory(dir);
			
			if (!noServer)
			{
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
			}
			
			if (!noClient)
			{
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
		}
		
		log.finishOk();
	}
	
	function generateComponentsCssFile(manager:HaqTemplateManager, binDir:String)
	{
		log.start("Generate style file");
		
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
		
		log.finishOk();
	}
	
	function generateMobilePages(manager:HaqTemplateManager, outputDir:String)
	{
		log.start("Generate mobile pages");
		
		try
		{
			for (fullTag in manager.fullTags)
			{
				if (fullTag.startsWith(HaqDefines.folders.pages + "."))
				{
					var path = outputDir + "/" + fullTag.replace(".", "/") + "/index.html";
					FileSystem.createDirectory(Path.directory(path));
					
					var template = manager.get(fullTag);
					var doc = template.getDocCopy();
					renderComponents("", template, doc, manager, { nextAnonimID:0 });
					
					File.saveContent(path, doc.toString());
				}
			}
		}
		catch (e:Dynamic)
		{
			log.trace(e);
			log.trace(haxe.Stack.toString(haxe.Stack.exceptionStack()));
			log.finishFail(e);
		}
		
		log.finishOk();
	}
	
	function renderComponents(prefixID:String, parent:HaqTemplate, doc:HtmlNodeElement, manager:HaqTemplateManager, nextAnonimID:{ nextAnonimID:Int })
	{
		for (node in doc.children)
		{
			if (node.name.startsWith("haq:"))
			{
				var tag = node.name.substr("haq:".length).replace("-", ".");
				var id = node.getAttribute("id");
				if (id == null || id == "")
				{
					nextAnonimID.nextAnonimID++;
					id = "haqc_" + Std.string(nextAnonimID.nextAnonimID);
				}
				var childPrefixID = prefixID != "" ? prefixID + id + HaqDefines.DELIMITER : id + HaqDefines.DELIMITER;
				var childTemplate = manager.resolveComponentTag(parent, tag);
				if (childTemplate == null)
				{
					throw "Component '" + tag + "' used in '" + parent.fullTag + "' can not be resolved.";
				}
				var childDoc = childTemplate.getDocCopy();
				renderComponents(childPrefixID, childTemplate, childDoc, manager, { nextAnonimID:0 });
				doc.replaceChildWithInner(node, childDoc);
			}
			else
			{
                var nodeID = node.getAttribute('id');
                if (nodeID != null && nodeID != '')
				{
					node.setAttribute('id', prefixID + nodeID);
				}
                if (node.name == 'label')
                {
                    var nodeFor = node.getAttribute('for');
                    if (nodeFor != null && nodeFor != '')
					{
						node.setAttribute('for', prefixID + nodeFor);
					}
                }
				
				renderComponents(prefixID, parent, node, manager, nextAnonimID);
			}
		}
	}
}
package ;

import hant.FlashDevelopProject;
import hant.Log;
import hant.FileSystemTools;
import hant.PathTools;
import hant.Process;
import stdlib.Exception;
import haxe.htmlparser.HtmlNodeElement;
import haxe.Serializer;
import neko.Lib;
import sys.io.File;
import haxe.io.Path;
import haquery.common.HaqDefines;
import stdlib.FileSystem;
using stdlib.StringTools;
using Lambda;

class CompilationFailException extends Exception
{
	override public function toString() return message;
}

class Build 
{
	var log : Log;
    var fs : FileSystemTools;
	var exeDir : String;
	var is64 : Bool;
    
	var project : FlashDevelopProject;

	public function new(log:Log, fs:FileSystemTools, exeDir:String, is64:Bool, projectFilePath:String) 
	{
		this.log = log;
		this.fs = fs;
		this.exeDir = PathTools.path2normal(exeDir) + "/";
		this.is64 = is64;
		project = new FlashDevelopProject(projectFilePath);
	}
	
	public function build(outputDir:String, isDeadCodeElimination:Bool, basePage:String, staticUrlPrefix:String, htmlSubstitutes:Array<String>, ignorePages:Array<String>)
    {
        log.start("Build");
        
		try
		{
			var manager = new HaqTemplateManager(log, project.allClassPaths, basePage, staticUrlPrefix, parseSubstitutes(htmlSubstitutes), ignorePages.map(function(s) return Path.addTrailingSlash(s.replace("\\", "/"))));
			
			fs.createDirectory("gen/haquery/common");
			File.saveContent("gen/haquery/common/Generated.hx", "package haquery.common;\n\nclass Generated\n{\n\tpublic static inline var staticUrlPrefix = \"" + staticUrlPrefix + "\";\n}");
			
			fs.createDirectory("gen/haquery/server");
			File.saveContent("gen/haquery/server/BasePage.hx", "package haquery.server;\n\ntypedef BasePage = " + (basePage != "" && project.findFile(basePage.replace(".", "/") + "/Server.hx") != null ? basePage + ".Server" : "haquery.server.HaqPage") + ";\n");
			
			fs.createDirectory("gen/haquery/client");
			File.saveContent("gen/haquery/client/BasePage.hx", "package haquery.client;\n\ntypedef BasePage = " + (basePage != "" && project.findFile(basePage.replace(".", "/") + "/Client.hx") != null  ? basePage + ".Client" : "haquery.client.HaqPage") + ";\n");
			
			genTrm(manager);
			generateConfigClasses(manager);
			generateImports(manager, project.srcPath);
			
			genCodeFromServer(project);
			
			try saveLibFolderFileTimes(outputDir) catch (e:Dynamic) {}
			
			buildClient(outputDir, isDeadCodeElimination);
			buildServer(outputDir);
			
			generateComponentsCssFile(manager, outputDir);
			
			var publisher = new Publisher(log, fs, project.platform, is64);
			
			log.start("Publish to '" + outputDir + "'");
				for (path in project.allClassPaths)
				{
					publisher.prepare(path, manager.fullTags, project.allClassPaths);
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
		fo.writeString(Lambda.map(manager.fullTags, function(s) return "import " + s + ".ConfigServer;").join('\n'));
		fo.writeString("\n\n#elseif client\n\n");
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
	
	function buildClient(outputDir:String, isDeadCodeElimination:Bool)
    {
		var clientPath = outputDir + '/haquery/client';
		
		log.start("Build client");
        
		if (FileSystem.exists(clientPath + "/haquery.js"))
		{
			fs.rename(clientPath + "/haquery.js", clientPath + "/haquery.js.old");
		}
		if (FileSystem.exists(clientPath + "/haquery.js.map"))
		{
			fs.rename(clientPath + "/haquery.js.map", clientPath + "/haquery.js.map.old");
		}
		
		fs.createDirectory(clientPath);
        
        var params = project.getBuildParams("js", clientPath + "/haquery.js", [ "noEmbedJS", "client" ]);
		if (isDeadCodeElimination) params.push("--dead-code-elimination");
		var r = Process.run(log, fs.getHaxePath(), params);
		Lib.print(r.output);
		Lib.print(r.error);
		
		if (FileSystem.exists(clientPath + "/haquery.js")
		 && FileSystem.exists(clientPath + "/haquery.js.old"))
		{
			fs.restoreFileTimes(clientPath + "/haquery.js.old", clientPath + "/haquery.js");
			fs.deleteFile(clientPath + "/haquery.js.old");
		}
		if (FileSystem.exists(clientPath + "/haquery.js.map")
		 && FileSystem.exists(clientPath + "/haquery.js.map.old"))
		{
			fs.restoreFileTimes(clientPath + "/haquery.js.map.old", clientPath + "/haquery.js.map");
			fs.deleteFile(clientPath + "/haquery.js.map.old");
		}
		
		if (r.exitCode == 0)
		{
			log.finishOk();
		}
		else
		{
			log.finishFail("Client compilation errors.");
		}
    }
	
	function buildServer(outputDir:String)
	{
		log.start("Build server");
        var params = project.getBuildParams(project.platform, project.platform != "neko" ? outputDir : outputDir + "/index.n", [ "server" ]);
		var r = Process.run(log, fs.getHaxePath(), params);
		Lib.print(r.output);
		Lib.print(r.error);
		
		if (r.exitCode == 0)
		{
			log.finishOk();
		}
		else
		{
			log.finishFail("Server compilation errors.");
		}
	}
	
    public function genTrm(manager:HaqTemplateManager)
    {
        log.start("Generate template classes");
        
        TrmGenerator.run(manager, fs);
        
        log.finishOk();
    }
	
	function genCodeFromServer(project:FlashDevelopProject)
	{
		log.start("Generate source code files");
		var params = project.getBuildParams(project.platform, null, [ "haqueryGenCode", "server" ]);
		var r = Process.run(log, fs.getHaxePath(), params, true);
		if (r.output.trim() != "") Lib.print(r.output);
		if (r.error.trim() != "") Lib.print(r.error);
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
		log.start("Generate style file");
		
		var dir = binDir + "/haquery/client";
		FileSystem.createDirectory(dir);
		
		var addedCssBlocks = [];
		var text = "";
		for (fullTag in manager.fullTags)
		{
			var template = manager.get(fullTag);
			if (template.cssBlocks.length > 0)
			{
				var isHeaderAdded = false;
				for (css in template.cssBlocks)
				{
					if (!Lambda.has(addedCssBlocks, css))
					{
						if (!isHeaderAdded)
						{
							text += "/" + "* " + fullTag + "*" + "/\n";
							isHeaderAdded = true;
						}
						text += css + "\n";
						addedCssBlocks.push(css);
					}
				}
				text += "\n";
			}
		}
		
		File.saveContent(dir + "/haquery.css", text);
		
		log.finishOk();
	}
	
	/*
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
	}*/
	
	function parseSubstitutes(substitutes:Array<String>) : Array<{ from:EReg, to:String }>
	{
		return substitutes.map(function(s)
		{
			var parts = s.split(s.substr(0, 1));
			if (parts.length != 3)
			{
				throw "Can't parse regular expression '" + s + "'.";
			}
			
			try
			{
				return { from:new EReg(parts[1], "g"), to:parts[2] };
			}
			catch (e:Dynamic)
			{
				throw "Can't parse regular expression '" + s + "'.";
				return null;
			}
		});
	}
}
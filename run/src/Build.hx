import hant.FileSystemTools;
import hant.FlashDevelopProject;
import hant.HaxeCompiler;
import hant.Haxelib;
import hant.Log;
import hant.Path;
import hant.Process;
import haxe.Serializer;
import stdlib.Exception;
import stdlib.FileSystem;
import sys.io.File;
using stdlib.StringTools;
using Lambda;

class Build 
{
	var project : FlashDevelopProject;
	var port : Int;

	public function new(project:FlashDevelopProject, port:Int) 
	{
		this.project = project;
		this.port = port;
	}
	
	public function build(basePage:String, staticUrlPrefix:String, htmlSubstitutes:Array<String>, onlyPagesPackage:Array<String>, ignorePages:Array<String>)
    {
        Log.start("Build");
        
		Log.start("Collect pages and components data");
		var manager = new HaqTemplateManager
		(
			project.allClassPaths,
			basePage,
			staticUrlPrefix,
			parseSubstitutes(htmlSubstitutes),
			onlyPagesPackage,
			ignorePages.map(function(s) return Path.addTrailingSlash(s.replace("\\", "/")))
		);
		Log.finishSuccess();
		
		saveContentToFileIfNeed("gen/haquery/common/Generated.hx", "package haquery.common;\n\nclass Generated\n{\n\tpublic static inline var staticUrlPrefix = \"" + staticUrlPrefix + "\";\n}");
		saveContentToFileIfNeed("gen/haquery/server/BasePage.hx", "package haquery.server;\n\ntypedef BasePage = " + (basePage != "" && project.findFile(basePage.replace(".", "/") + "/Server.hx") != null ? basePage + ".Server" : "haquery.server.HaqPage") + ";\n");
		saveContentToFileIfNeed("gen/haquery/client/BasePage.hx", "package haquery.client;\n\ntypedef BasePage = " + (basePage != "" && project.findFile(basePage.replace(".", "/") + "/Client.hx") != null  ? basePage + ".Client" : "haquery.client.HaqPage") + ";\n");
		
		genTrm(manager);
		generateConfigClasses(manager);
		generateImports(manager);
		
		genCodeFromServer();
		
		try saveLibFolderFileTimes() catch (e:Dynamic) {}
		
		buildClient();
		buildServer();
		
		generateComponentsCssFile(manager);
		
		var publisher = new Publisher(project.platform, project.directives);
		
		Log.start("Publish to '" + project.outputPath + "'");
			for (path in project.allClassPaths)
			{
				publisher.prepare(path, manager.fullTags, project.allClassPaths.concat([ Haxelib.getPath("jquery") ]));
			}
			publisher.publish(project.outputPath);
		Log.finishSuccess();
		
		loadLibFolderFileTimes();
		
		Log.finishSuccess();
    }
    
	function generateImports(manager:HaqTemplateManager)
    {
        Log.start("Generate imports");
        
        FileSystemTools.createDirectory("gen");
		
		var s = "";
		s += "#if server\n\n";
		s += Lambda.map(manager.fullTags, function(s) return "import " + s + ".ConfigServer;").join('\n');
		s += "\n\n#elseif client\n\n";
		s += Lambda.map(manager.fullTags, function(s) return "import " + s + ".ConfigClient;").join('\n');
		s += "\n\n#end\n";
		
		saveContentToFileIfNeed("gen/Imports.hx", s);
        
        Log.finishSuccess();
    }
	
    function strcmp(a:String, b:String) : Int
    {
        if (a == b) return 0;
		return a < b ? -1 : 1;
    }
	
	function buildClient()
    {
		var clientPath = project.outputPath + "/haquery";
		
		Log.start("Build client");
        
		if (FileSystem.exists(clientPath + "/haquery.js"))
		{
			FileSystemTools.rename(clientPath + "/haquery.js", clientPath + "/haquery.js.old");
		}
		if (FileSystem.exists(clientPath + "/haquery.js.map"))
		{
			FileSystemTools.rename(clientPath + "/haquery.js.map", clientPath + "/haquery.js.map.old");
		}
		
		FileSystemTools.createDirectory(clientPath);
        
        var params = project.getBuildParams("js", clientPath + "/haquery.js", [ "noEmbedJS", "client" ]);
		var exitCode = HaxeCompiler.run(params, port, true);
		
		if (FileSystem.exists(clientPath + "/haquery.js")
		 && FileSystem.exists(clientPath + "/haquery.js.old"))
		{
			FileSystemTools.restoreFileTimes(clientPath + "/haquery.js.old", clientPath + "/haquery.js");
			FileSystemTools.deleteFile(clientPath + "/haquery.js.old");
		}
		if (FileSystem.exists(clientPath + "/haquery.js.map")
		 && FileSystem.exists(clientPath + "/haquery.js.map.old"))
		{
			FileSystemTools.restoreFileTimes(clientPath + "/haquery.js.map.old", clientPath + "/haquery.js.map");
			FileSystemTools.deleteFile(clientPath + "/haquery.js.map.old");
		}
		
		if (exitCode == 0)
		{
			Log.finishSuccess();
		}
		else
		{
			throw new CompilationFailException();
		}
    }
	
	function buildServer()
	{
		Log.start("Build server");
        
		var params = project.getBuildParams(null, project.outputPath + (project.platform == "neko" ? "/index.n" : ""), [ "server" ]);
		var exitCode = HaxeCompiler.run(params, port);
		
		if (exitCode == 0)
		{
			Log.finishSuccess();
		}
		else
		{
			throw new CompilationFailException();
		}
	}
	
    public function genTrm(manager:HaqTemplateManager)
    {
        Log.start("Generate template classes");
        
        TrmGenerator.run(manager);
        
        Log.finishSuccess();
    }
	
	function genCodeFromServer()
	{
		Log.start("Generate source code files");
		var params = project.getBuildParams(null, null, [ "haqueryGenCode", "server" ]);
		params.push("--no-output");
		var exitCode = HaxeCompiler.run(params, port);
		if (exitCode == 0)
		{
			Log.finishSuccess();
		}
		else
		{
			throw new CompilationFailException();
		}
	}
	
	function saveLibFolderFileTimes()
	{
		if (FileSystem.exists(project.outputPath + "/lib"))
		{
			Log.start("Save file times of the " + project.outputPath + "/lib folder");
			loadLibFolderFileTimes();
			FileSystemTools.rename(project.outputPath + "/lib", project.outputPath + "/lib.old");
			Log.finishSuccess();
		}
	}

	function loadLibFolderFileTimes()
	{
		if (FileSystem.exists(project.outputPath + "/lib.old"))
		{
			Log.start("Load lib folder file times");
			FileSystemTools.restoreFileTimes(project.outputPath + "/lib.old", project.outputPath + "/lib", ~/[.](?:php|js)/i);
			FileSystemTools.deleteDirectory(project.outputPath + "/lib.old");
			Log.finishSuccess();
		}
	}
	
	function generateConfigClasses(manager:HaqTemplateManager)
	{
		Log.start("Generate config classes");
		
		for (fullTag in manager.fullTags)
		{
			var template = manager.get(fullTag);
			var dir = "gen/" + fullTag.replace(".", "/");
			FileSystem.createDirectory(dir);
			
			saveContentToFileIfNeed(dir + "/ConfigServer.hx"
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
			
			
			var path = dir + "/ConfigClient.hx";
			if (FileSystem.exists(path))
			{
				var lines = File.getContent(path).split("\n");
				for (i in 0...lines.length)
				{
					if (lines[i].startsWith("package "))
					{
						lines[i] = "package " + fullTag + ";";
					}
					else
					if (lines[i].startsWith("import "))
					{
						lines[i] = "import " + template.clientClassName + ";";
					}
					else
					if (lines[i].startsWith("\tpublic static var clientClassName = "))
					{
						lines[i] = "\tpublic static var clientClassName = '" + template.clientClassName + "';"; 
					}
				}
				var content = lines.join("\n");
				if (File.getContent(path) != content)
				{
					File.saveContent(path, content);
				}
			}
			else
			{
				File.saveContent(path
					, "// This is autogenerated file. Do not edit!\n\n"
					+ "package " + fullTag + ";\n\n"
					+ "import " + template.clientClassName + ";\n\n"
					+ "@:keep class ConfigClient\n"
					+ "{\n"
					+ "\tpublic static var clientClassName = '" + template.clientClassName + "';\n"
					+ "\tpublic static function getServerHandlers() : Array<String> return [];\n"
					+ "}\n"
				);
			}
		}
		
		Log.finishSuccess();
	}
	
	function generateComponentsCssFile(manager:HaqTemplateManager)
	{
		Log.start("Generate style file");
		
		var dir = project.outputPath + "/haquery";
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
		
		Log.finishSuccess();
	}
	
	function saveContentToFileIfNeed(file:String, content:String)
	{
		if (!FileSystem.exists(file) || File.getContent(file) != content)
		{
			FileSystemTools.createDirectory(Path.directory(file), false );
			File.saveContent(file, content);
		}
	}
	
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
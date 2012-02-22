package haquery.tools.tasks;

import haquery.server.FileSystem;
import haquery.server.io.File;
import haquery.server.io.FileOutput;
import haquery.server.io.Path;
import haquery.server.HaqDefines;
import haquery.tools.HaqTemplateManager;
import neko.Lib;

import haquery.tools.trm.TrmGenerator;

import haquery.tools.FlashDevelopProject;
import haquery.tools.ComponentFileKind;

using haquery.StringTools;
using haquery.HashTools;

class Build 
{
	var exeDir : String;
	var haxePath : String;
    
	var log : Log;
    var hant : Hant;
	var project : FlashDevelopProject;
	var componentFileKind : ComponentFileKind;

	public function new(exeDir:String, haxePath:String) 
	{
		this.exeDir = exeDir.replace('\\', '/').rtrim('/') + '/';
		this.haxePath = haxePath.replace('\\', '/').rtrim('/') + '/';
        
		log = new Log(2);
        hant = new Hant(log, this.exeDir);
		project = new FlashDevelopProject('.', this.exeDir);
		componentFileKind = new ComponentFileKind(this.exeDir);
	}
	
    function genImports(manager:HaqTemplateManager)
    {
        log.start("Generate imports to 'src/Imports.hx'");
        
        var fo = File.write("src/Imports.hx", false);
        
        var serverClassNames = new Hash<Int>();
        var clientClassNames = new Hash<Int>();
		for (fullTag in manager.getLastMods().keys())
		{
			serverClassNames.set(manager.get(fullTag).serverClassName, 1);
			clientClassNames.set(manager.get(fullTag).clientClassName, 1);
		}
		
		var arrServerClassNames = Lambda.array(serverClassNames.keysIterable());
		arrServerClassNames.sort(strcmp);
		
		var arrClientClassNames = Lambda.array(clientClassNames.keysIterable());
		arrClientClassNames.sort(strcmp);
		
		fo.writeString("#if (php || neko)\n\n");
		fo.writeString(Lambda.map(findBootstrapClassNames(HaqDefines.folders.pages), function(s) return "import " + s + ";").join('\n'));
		fo.writeString("\n");
		fo.writeString("\n");
		fo.writeString(Lambda.map(arrServerClassNames, function(s) return "import " + s + ";").join('\n'));
		fo.writeString("\n\n#elseif js\n\n");
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
	
	function findBootstrapClassNames(path:String) : List<String>
	{
		var files = hant.findFiles('src/' + path, function(s) return s.endsWith("/Bootstrap.hx"));
		return Lambda.map(files, function(s) return s.substr('src/'.length, s.length - 'src/'.length - ".hx".length).replace("/", "."));
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
            if (path != exeDir)
			{
				params.push('-cp'); params.push(path.rtrim('/'));
			}
        }
		
		params = params.concat([ 
			 "-lib", "HaQuery"
			,"-js", clientPath + "/haquery.js"
			,'-main', 'Main'
		]);
		
		if (project.isDebug)
		{
			params.push("-debug");
		}
		
		params = params.concat([ '-D', 'noEmbedJS' ]);		
		
		Lib.print("\n    " + haxePath.replace("/", "\\") + "haxe.exe " + params.join(" ") + "\n  ");
		hant.run(haxePath + "haxe.exe", params);
		
        
		if (FileSystem.exists(clientPath + "/haquery.js")
		 && FileSystem.exists(clientPath + "/haquery.js.old"))
		{
			hant.restoreFileTime(clientPath + "/haquery.js.old", clientPath + "/haquery.js");
			hant.deleteFile(clientPath + "/haquery.js.old");
		}
		
		log.finishOk();
    }
	
	public function preBuild()
    {
        log.start("Do pre-build step");
        
		var manager = new HaqTemplateManager(project.classPaths);
		
		genTrm(manager);
		
		genImports(manager);
		
		saveLastMods(manager.getLastMods());
		
		try { saveLibFolder(); } catch (e:Dynamic) { }
        
        log.finishOk();
    }
	
	function saveLastMods(lastMods:Hash<Date>)
	{
		var serverPath = project.binPath + '/haquery/server';
		if (!FileSystem.exists(serverPath))
		{
			FileSystem.createDirectory(serverPath);
		}
		File.putContent(
			 serverPath + "/templates.dat"
			,Lambda.map(lastMods.keysIterable(), function(fullTag) {
				return fullTag + "\t" + Math.round(lastMods.get(fullTag).getTime()/1000000.0);
			}
		).join("\n"));
	}
	
    public function genTrm(?manager:HaqTemplateManager)
    {
        log.start("Generate template related mapping classes");
        
        TrmGenerator.run(manager!=null ? manager : new HaqTemplateManager(project.classPaths));
        
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
		
		removeTempFiles();
        
        log.finishOk();
    }
	
	function removeTempFiles()
	{
		var tempFileNames = [ 
			 "templates-cache-server.dat"
			,"templates-cache-client.js"
			,"templates-cache-client.css"
		];
		
		for (classPath in project.classPaths)
		{
			for (file in tempFileNames)
			{
				var path = classPath + HaqDefines.folders.temp + "/" + file;
				if (FileSystem.exists(path))
				{
					FileSystem.deleteFile(path);
				}
			}
		}
	}
}
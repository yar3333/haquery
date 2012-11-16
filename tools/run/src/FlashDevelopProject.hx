package ;

import hant.Log;
import hant.PathTools;
import hant.Process;
import haquery.Exception;
import haquery.server.FileSystem;
import sys.io.File;
import haquery.Std;
using haquery.StringTools;

class FlashDevelopProject 
{
	var log : Log;
	
	//public var binPath(default, null) : String;
	public var classPaths(default, null) : Array<String>;
	public var libPaths(default, null) : Hash<String>;
	public var allClassPaths(default, null) : Array<String>;
	public var isDebug(default, null) : Bool;
	public var srcPath(default, null) : String;
	public var platform(default, null) : String;
	public var additionalCompilerOptions(default, null) : Array<String>;
	
	public function new(log:Log, dir:String) 
	{
		this.log = log;
		
		var projectFilePath = findProjectFile(dir);
		if (projectFilePath == null)
		{
			throw new Exception("FlashDevelop project file not found.");
		}
		
		var xml = Xml.parse(File.getContent(projectFilePath));
		
		//binPath = getBinPath(xml);
		classPaths = getClassPaths(xml);
		libPaths = getLibPaths(xml);
		allClassPaths = Lambda.array(libPaths).concat(classPaths);
		isDebug = getIsDebug(xml);
		srcPath = getSrcPath(xml);
		platform = getPlatform(xml);
		additionalCompilerOptions = getAdditionalCompilerOptions(xml);
	}
	
	function findProjectFile(dir:String) : String
	{
		dir = dir.trim();
		if (dir == "") dir = ".";
		dir = dir.replace("\\", "/").rtrim("/");
		
		for (file in FileSystem.readDirectory(dir))
		{
			if (file.endsWith(".hxproj") && !FileSystem.isDirectory(dir + "/" + file))
			{
				return  dir + "/" + file;
			}
		}
		
		return null;
	}
	
	/*function getBinPath(xml:Xml) : String
	{
		var fast = new haxe.xml.Fast(xml.firstElement());
		
		if (fast.hasNode.output)
		{
			for (elem in fast.node.output.elements)
			{
				if (elem.name == "movie" && elem.has.bin)
				{
					return elem.att.bin;
				}
			}
		}
		
		return "bin";
	}*/
	
    function getClassPaths(xml:Xml) : Array<String>
    {
        var r = new Array<String>();
		var fast = new haxe.xml.Fast(xml.firstElement());
		
		if (fast.hasNode.classpaths)
		{
			var classpaths = fast.node.classpaths;
			for (elem in classpaths.elements)
			{
				if (elem.name == 'class' && elem.has.path)
				{
					var path = elem.att.path.trim().replace('\\', '/').rtrim('/');
					if (path == "")
					{
						path = ".";
					}
					r.push(path.rtrim("/") + "/");
				}
			}
		}
		
		return r;
    }
	
    function getLibPaths(xml:Xml) : Hash<String>
    {
        var r = new Hash<String>();
		var fast = new haxe.xml.Fast(xml.firstElement());
		
		var libs = new Array<String>();
		if (fast.hasNode.haxelib)
		{
			var haxelibs = fast.node.haxelib;
			for (elem in haxelibs.elements)
			{
				if (elem.name == 'library' && elem.has.name)
				{
					libs.push(elem.att.name);
				}
			}
		}
		
		var lines = Process.run(log, PathTools.path2normal(Sys.environment().get("HAXEPATH")) + "/haxelib.exe", [ "path" ].concat(libs)).stdOut.split("\n");
		for (i in 0...lines.length)
		{
			if (lines[i].startsWith("-D "))
			{
				var lib = lines[i].substr("-D ".length);
				if (Lambda.has(libs, lib))
				{
					var path = lines[i - 1].trim();
					if (path == "") path = ".";
					var p = path.replace("\\", "/").rtrim("/") + "/";
					r.set(lib.toLowerCase(), p);
				}
			}
		}
		
		return r;
    }
	
	function getIsDebug(xml:Xml) : Bool
	{
		var fast = new haxe.xml.Fast(xml.firstElement());
		if (fast.hasNode.build)
		{
			for (elem in fast.node.build.elements)
			{
				if (elem.name == 'option' && elem.has.enabledebug)
				{
					return Std.bool(elem.att.enabledebug);
				}
			}
		}
		return true;
	}
	
	function getSrcPath(xml:Xml) : String
	{
		var r = "src/";
		
		var fast = new haxe.xml.Fast(xml.firstElement());		
		
		if (fast.hasNode.classpaths)
		{
			var classpaths = fast.node.classpaths;
			for (elem in classpaths.elements)
			{
				if (elem.name == 'class' && elem.has.path)
				{
					var path = elem.att.path.trim().replace('\\', '/').rtrim('/');
					if (path == "")
					{
						path = ".";
					}
					r = path.rtrim("/") + "/";
				}
			}
		}
		
		return r;
	}

	function getPlatform(xml:Xml) : String
	{
		var fast = new haxe.xml.Fast(xml.firstElement());
		
		if (fast.hasNode.output)
		{
			for (elem in fast.node.output.elements)
			{
				if (elem.name == "movie" && elem.has.platform)
				{
					return elem.att.platform.toLowerCase();
				}
			}
		}
		
		return "";
	}
	
	function getAdditionalCompilerOptions(xml:Xml) : Array<String>
	{
		var fast = new haxe.xml.Fast(xml.firstElement());
		
		if (fast.hasNode.build)
		{
			for (elem in fast.node.build.elements)
			{
				if (elem.name == "option" && elem.has.additional)
				{
					var s = StringTools.urlDecode(elem.att.additional).trim();
					return s != "" ? ~/\s+/.split(s) : [];
				}
			}
		}
		
		return [];
	}
	
	public function findFile(relativeFilePath:String) : String
	{
		var i = allClassPaths.length - 1;
		while (i >= 0)
		{
			if (FileSystem.exists(allClassPaths[i] + relativeFilePath))
			{
				return allClassPaths[i] + relativeFilePath;
			}
			i--;
		}
		return null;
	}
	
	public function getBuildParams(platform:String, destPath:String, defines:Array<String>) : Array<String>
	{
        var params = new Array<String>();
        
		for (path in classPaths)
        {
			params.push("-cp"); params.push(path.rtrim("/"));
        }
        
		for (name in libPaths.keys())
        {
			params.push("-lib"); params.push(name);
		}
		
		params.push("-" + platform);
		params.push(destPath);
		
		params.push("-main");
		params.push("Main");
		
		if (isDebug)
		{
			params.push("-debug");
		}
		
		for (d in defines)
		{
			params = params.concat([ "-D", d ]);
		}
		
		params = params.concat(additionalCompilerOptions);
		
		return params;
	}
}
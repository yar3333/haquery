package haquery.tools;

import haquery.server.FileSystem;
import haquery.server.io.File;
import haquery.Std;

using haquery.StringTools;

class FlashDevelopProject 
{
	public var binPath(default, null) : String;
	public var classPaths(default, null) : Array<String>;
	public var isDebug(default, null) : Bool;
	
	public function new(dir:String, exeDir:String) 
	{
		var projectFilePath = findProjectFile(dir);
		if (projectFilePath == null)
		{
			throw "FlashDevelop project file not found.";
		}
		
		var xml = Xml.parse(File.getContent(projectFilePath));
		
		binPath = getBinPath(xml);
		classPaths = getClassPaths(xml, exeDir);
		isDebug = getIsDebug(xml);
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
	
	function getBinPath(xml:Xml) : String
	{
		var fast = new haxe.xml.Fast(xml.firstElement());
		if (fast.hasNode.output && fast.node.output.hasNode.movie)
		{
			var movie = fast.node.output.node.movie;
			if (movie.has.path)
			{
				return movie.att.path.replace("\\", "/").rtrim("/");
			}
		}
		return "bin";
	}
	
    function getClassPaths(xml:Xml, exeDir:String) : Array<String>
    {
        var r = new Array<String>();
        
		r.push(exeDir);
		
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
					r.push(path + "/");
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
}
package haquery.tools;

import haquery.server.FileSystem;
import haquery.server.io.File;
import haquery.server.io.Path;

using haquery.StringTools;
using haquery.HashTools;

class Excludes 
{
	var libPaths : Hash<String>;
	
	var reGlobals : Array<String>;
	var reLocals : Hash<Array<String>>;

	public function new(libPaths:Hash<String>) 
	{
		this.libPaths = libPaths;
		this.reGlobals = new Array<String>();
		this.reLocals = new Hash<Array<String>>();
	}
	
	public function appendFromFile(excludeFilePath:String)
	{
		var xml = Xml.parse(File.getContent(excludeFilePath));
		
		var fast = new haxe.xml.Fast(xml.firstElement());
		
		if (fast.hasNode.global)
		{
			for (elemRegexp in fast.node.global.elements)
			{
				if (elemRegexp.name == "regexp" && elemRegexp.has.pattern)
				{
					reGlobals.push(elemRegexp.att.pattern);
				}
			}
		}
		
		for (elemLibrary in fast.elements)
		{
			if (elemLibrary.name == "library" && elemLibrary.has.name)
			{
				var localPath = libPaths.get(elemLibrary.att.name.toLowerCase());
				if (localPath != null)
				{
					for (elemRegexp in elemLibrary.elements)
					{
						if (elemRegexp.name == "regexp" && elemRegexp.has.pattern)
						{
							if (!reLocals.exists(localPath))
							{
								reLocals.set(localPath, new Array<String>());
							}
							reLocals.get(localPath).push(elemRegexp.att.pattern);
						}
					}
				}
			}
		}
		
		var localPath = Path.directory(FileSystem.fullPath(excludeFilePath)).replace("\\", "/").rtrim("/") + "/";
		for (elemLocal in fast.elements)
		{
			if (elemLocal.name == "local")
			{
				for (elemRegexp in elemLocal.elements)
				{
					if (elemRegexp.name == "regexp" && elemRegexp.has.pattern)
					{
						if (!reLocals.exists(localPath))
						{
							reLocals.set(localPath, new Array<String>());
						}
						reLocals.get(localPath).push(elemRegexp.att.pattern);
					}
				}
			}
		}
	}
	
	public function getRegExp(srcPath:String) : String
	{
		srcPath = FileSystem.fullPath(srcPath).replace("\\", "/").rtrim("/") + "/";
		
		var r = Reflect.copy(reGlobals);
		for (localPath in reLocals.keysIterable())
		{
			if (localPath == srcPath)
			{
				var pattern = localPath.replace(".", "[.]")
							+ "(?:" + Lambda.map(reLocals.get(localPath), function(s) return "(?:" + s + ")").join("|") + ")";
				r.push(pattern);
			}
		}
		
		return Lambda.map(r, function(s) return "(?:" + s + ")").join("|");
	}
}
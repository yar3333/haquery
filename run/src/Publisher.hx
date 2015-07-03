import hant.Haxelib;
import hant.Log;
import hant.FileSystemTools;
import hant.Path;
import hant.Process;
import stdlib.FileSystem;
import sys.io.File;
import htmlparser.HtmlDocument;
import htmlparser.HtmlNodeElement;
using stdlib.StringTools;

class Publisher 
{
	var defines : Array<String>;
	var exeDir : String;
	
	/**
	 * dest => src
	 */
	var files : Map<String,String>;
	
	public function new(platform:String, defines:Array<String>)
	{
		this.defines = [ platform ].concat(defines);
		this.files = new Map<String,String>();
	}
	
	public function prepare(src:String, fullTags:Array<String>, allClassPaths:Array<String>) : Void
	{
		src = Path.normalize(src);
		allClassPaths = allClassPaths.map(Path.normalize);
		
		if (fullTags != null)
		{
			prepareComponents(src + "/components", "components", "components", fullTags);
			prepareComponents(src + "/pages", "pages", "pages", fullTags);
		}
		
		prepareFile(src + "/config.xml", "config.xml");
		
		prepareFolder(src + "/ndll", "ndll", "", null, null);
		
		var configFile = src + "/publish.xml";
		if (FileSystem.exists(configFile))
		{
			var xml = new HtmlDocument(File.getContent(configFile));
			
			for (node in xml.find(">publish>*"))
			{
				switch (node.name)
				{
					case "dir":
						if (checkConditions(node))
						{
							var srcAttr = node.getAttribute("src");
							if (srcAttr == null || srcAttr == "") throw "Tag 'dir' must have not empty 'src' attribute in file '" + configFile + "'.";
							var destAttr = node.hasAttribute("dest") ? node.getAttribute("dest") : srcAttr;
							var includeAttr = node.hasAttribute("include") ? node.getAttribute("include") : null;
							var excludeAttr = node.hasAttribute("exclude") ? node.getAttribute("exclude") : null;
							prepareFolder
							(
								  getFullPath(src, srcAttr, allClassPaths)
								, destAttr
								, ""
								, includeAttr != null ? new EReg(includeAttr, "i") : null
								, excludeAttr != null ? new EReg(excludeAttr, "i") : null
							);
						}
					
					case "file":
						if (checkConditions(node))
						{
							var srcAttr = node.getAttribute("src");
							if (srcAttr == null || srcAttr == "") throw "Tag 'dir' must have not empty 'src' attribute in file '" + configFile + "'.";
							var destAttr = node.hasAttribute("dest") ? node.getAttribute("dest") : srcAttr;
							prepareFile
							(
								  getFullPath(src, srcAttr, allClassPaths)
								, destAttr
							);
						}
					
					default:
						throw "Unknow tag '" + node.name + "'. Expected 'dir' or 'file'.";
				}
			}
		}
	}
	
	function checkConditions(node:HtmlNodeElement) : Bool
	{
		var platform = node.getAttribute("platform");
		if (platform != null && platform != "" && platform != defines[0]) return false;
		
		var define = node.getAttribute("if");
		if (!isDefined(define)) return false;
		
		var ifall = node.getAttribute("if-all");
		if (ifall != null)
		{
			for (define in ~/[ ,;\t\n\r]+/g.split(ifall))
			{
				if (!isDefined(define)) return false;
			}
		}
		
		var ifany = node.getAttribute("if-any");
		if (ifany != null)
		{
			ifany = ifany.trim();
			if (ifany != "")
			{
				for (define in ~/[ ,;\t\n\r]+/g.split(ifany))
				{
					if (define.trim() != "" && isDefined(define)) return true;
				}
				return false;
			}
		}
		
		return true;
	}
	
	function isDefined(define:String) : Bool
	{
		if (define == null) return true;
		define = define.trim();
		if (define == "") return true;
		if (!define.startsWith("!"))
		{
			if (defines.indexOf(define) >= 0) return true;
		}
		else
		{
			if (defines.indexOf(define) < 0) return true;
		}
		return false;
	}
	
	function prepareComponents(src:String, dest:String, pack:String, fullTags:Array<String>) : Void
	{
		src = Path.normalize(src);
		dest = Path.normalize(dest);
		
		if (FileSystem.exists(src) && FileSystem.isDirectory(src))
		{
			for (file in FileSystem.readDirectory(src))
			{
				var path = src + "/" + file;
				if (FileSystem.isDirectory(path))
				{
					if (file != "support")
					{
						if (Lambda.has(fullTags, pack + "." + file))
						{
							prepareFolder(path + "/support", dest + "/" + file + "/support", "", null, null);
						}
						prepareComponents(path, dest + "/" + file, pack + "." + file, fullTags);
					}
				}
			}
		}
	}
	
	function prepareFolder(src:String, dest:String, localPath:String, include:EReg, exclude:EReg) : Void
	{
		if (src != null && FileSystem.exists(src) && FileSystem.isDirectory(src))
		{
			for (file in FileSystem.readDirectory(src))
			{
				var path = src + "/" + file;
				var newLocalPath = localPath + (localPath != "" ? "/" : "") + file;
				if ((include == null || include.match(newLocalPath)) && (exclude == null || !exclude.match(newLocalPath)))
				{
					if (FileSystem.isDirectory(path))
					{
						prepareFolder(
							  path
							, dest + "/" + file
							, newLocalPath
							, include
							, exclude
						);
					}
					else
					{
						prepareFile(path, dest + "/" + file);
					}
				}
			}
		}
	}
	
	function prepareFile(src:String, dest:String)
	{
		if (src != null && FileSystem.exists(src))
		{
			files.set(dest, src);
		}
	}
	
	public function publish(destDir:String)
	{
		destDir = Path.normalize(destDir);
		
		for (destLocal in files.keys())
		{
			var src = files.get(destLocal);
			var dest = destDir + "/" + destLocal;
			if (!FileSystem.exists(dest) || FileSystem.stat(src).mtime.getTime() > FileSystem.stat(dest).mtime.getTime())
			{
				FileSystemTools.copyFile(src, dest);
			}
		}
	}
	
	function getFullPath(base:String, local:String, allClassPaths:Array<String>) : String
	{
		if (FileSystem.exists(base + "/" + local)) return base + "/" + local;
		var i = allClassPaths.length - 1; while (i >= 0)
		{
			if (FileSystem.exists(allClassPaths[i] + "/" + local)) return allClassPaths[i] + "/" + local;
			i--;
		}
		return null;
	}
}

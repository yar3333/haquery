package haquery.tools;

import haquery.server.FileSystem;
import haxe.io.Path;
import haxe.htmlparser.HtmlDocument;
import haxe.htmlparser.HtmlNodeElement;
import sys.io.File;
using haquery.StringTools;

class Publisher 
{
	var exeDir : String;
	var platform : String;
	
	/**
	 * dest => src
	 */
	var files : Hash<String>;
	
	public function new(exeDir:String, platform:String)
	{
		this.exeDir = exeDir;
		this.platform = platform;
		this.files = new Hash<String>();
	}
	
	public function prepare(src:String, fullTags:Hash<Int>) : Void
	{
		src = src.rtrim("/");
		
		if (fullTags != null)
		{
			prepareComponents(src + "/components", "components", "components", fullTags);
			prepareComponents(src + "/pages", "pages", "pages", fullTags);
		}
		
		prepareFile(src + "/config.xml", "config.xml");
		
		prepareFolder(src + "/ndll", "ndll", "", null, null);
		
		/*
		<publish>
			<dir src="local_path" [ dest="new_path" ] [ include="regex" ] [ exclude="regex" ] [ platform="neko|php|js" ] />
			<file src="local_path_and_name" [ dest="new_path_and_name" ] [ platform="neko|php|js" ] />
		</publish>
		*/
		var configFile = src + "/publish.xml";
		if (FileSystem.exists(configFile))
		{
			var xml = new HtmlDocument(File.getContent(configFile));
			
			for (node in xml.find(">publish>*"))
			{
				switch (node.name)
				{
					case "dir":
						var platformAttr = node.getAttribute("platform");
						if (platformAttr == null || platformAttr == "" || platformAttr == platform)
						{
							var srcAttr = node.getAttribute("src");
							if (srcAttr == null || srcAttr == "") throw "Tag 'dir' must have not empty 'src' attribute in file '" + configFile + "'.";
							var destAttr = node.hasAttribute("dest") ? node.getAttribute("dest") : srcAttr;
							var includeAttr = node.hasAttribute("include") ? node.getAttribute("include") : null;
							var excludeAttr = node.hasAttribute("exclude") ? node.getAttribute("exclude") : null;
							prepareFolder(
								  src + "/" + srcAttr
								, destAttr
								, ""
								, includeAttr != null ? new EReg(includeAttr, "i") : null
								, excludeAttr != null ? new EReg(excludeAttr, "i") : null
							);
						}
					
					case "file":
						var platformAttr = node.getAttribute("platform");
						if (platformAttr == null || platformAttr == "" || platformAttr == platform)
						{
							var srcAttr = node.getAttribute("src");
							if (srcAttr == null || srcAttr == "") throw "Tag 'dir' must have not empty 'src' attribute in file '" + configFile + "'.";
							var destAttr = node.hasAttribute("dest") ? node.getAttribute("dest") : srcAttr;
							prepareFile(src + "/" + srcAttr, destAttr);
						}
					
					default:
						throw "Unknow tag '" + node.name + "'. Expected 'dir' or 'file'.";
				}
			}
		}
	}
	
	function prepareComponents(src:String, dest:String, pack:String, fullTags:Hash<Int>) : Void
	{
		if (FileSystem.exists(src) && FileSystem.isDirectory(src))
		{
			for (file in FileSystem.readDirectory(src))
			{
				var path = src + "/" + file;
				if (FileSystem.isDirectory(path))
				{
					if (file != "support")
					{
						if (fullTags.exists(pack + "." + file))
						{
							prepareFolder(path + "/support", dest + "/" + file + "/support", "", null, null);
							prepareFile(path + "/template.html", dest + "/" + file + "/template.html");
						}
						prepareComponents(path, dest + "/" + file, pack + "." + file, fullTags);
					}
				}
				else
				{
					if (file == "config.xml")
					{
						prepareFile(path, dest + "/" + file);
					}
				}
			}
		}
	}
	
	function prepareFolder(src:String, dest:String, localPath:String, include:EReg, exclude:EReg) : Void
	{
		if (FileSystem.exists(src) && FileSystem.isDirectory(src))
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
		if (FileSystem.exists(src))
		{
			files.set(dest, src);
		}
	}
	
	public function publish(destDir:String)
	{
		for (destLocal in files.keys())
		{
			var src = files.get(destLocal);
			var dest = destDir + "/" + destLocal;
			if (!FileSystem.exists(dest) || FileSystem.stat(src).mtime.getTime() > FileSystem.stat(dest).mtime.getTime())
			{
				FileSystem.createDirectory(Path.directory(dest));
				HaqNative.copyFilePreservingAttributes(exeDir, src, dest);
			}
		}
	}
}

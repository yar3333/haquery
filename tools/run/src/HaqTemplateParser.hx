package ;

import haquery.base.HaqTemplateParser.HaqTemplateNotFoundException;
import haquery.base.HaqTemplateParser.HaqTemplateNotFoundCriticalException;
import haquery.base.HaqTemplateParser.HaqTemplateRecursiveExtendException;
import haquery.common.HaqDefines;
import haquery.server.FileSystem;
import haxe.htmlparser.HtmlDocument;
import sys.io.File;

using StringTools;

class HaqTemplateParser extends haquery.server.HaqTemplateParser
{
	static inline var MIN_DATE = new Date(2000, 0, 0, 0, 0, 0);
	
	var classPaths : Array<String>;
	
	public function new(classPaths:Array<String>, fullTag:String, childFullTags:Array<String>)
	{
		this.classPaths = classPaths;
		super(fullTag, childFullTags);
	}
	
	override function isTemplateExist(fullTag:String) : Bool
	{
		var localPath = fullTag.replace(".", "/");
		var path = getFullPath(localPath);
		if (path != null && FileSystem.isDirectory(path))
		{
			if (
				getFullPath(localPath + '/template.html') != null
			 || getFullPath(localPath + '/Client.hx') != null
			 || getFullPath(localPath + '/Server.hx') != null
			) {
				return true;
			}
		}
		return false;
	}
	
	override function getParentParser() : haquery.server.HaqTemplateParser
	{
		if (config.extend == null || config.extend == "") return null; 
		try 
		{
			return new HaqTemplateParser(classPaths, config.extend, childFullTags.concat([fullTag]));
		}
		catch (e:HaqTemplateNotFoundException)
		{
			throw new HaqTemplateNotFoundCriticalException(e.toString());
		}
	}
	
	override function loadChildConfigDataToParent(parent:haquery.server.HaqTemplateConfig, child:haquery.server.HaqTemplateConfig) : Void
	{
		super.loadChildConfigDataToParent(parent, child);
		
		cast(parent, HaqTemplateConfig).requires = cast(parent, HaqTemplateConfig).requires.concat(cast(child, HaqTemplateConfig).requires);
	}
	
	override function parseConfig(xml:HtmlDocument) : haquery.server.HaqTemplateConfig
	{
		var b = super.parseConfig(xml);
		
		var r = new HaqTemplateConfig();
		r.extend = b.extend;
		r.imports = b.imports;
		
		if (xml != null)
		{
			for (node in xml.find(">config>requires>component"))
			{
				r.requires.push(node.getAttribute("package"));
			}
		}
		
		return r;
	}
	
	override function getFullPath(path:String) : String
	{
		if (path.startsWith("./"))
		{
			path = path.substr(2);
		}
		
		var i = classPaths.length - 1;
		while (i >= 0)
		{
			var fullPath = classPaths[i] + path;
			if (FileSystem.exists(fullPath))
			{
				return fullPath;
			}
			i--;
		}
		return null;
	}
	
	function getLocalClassName(shortClassName:String) : String
	{
		var fullClassName = fullTag + "." + shortClassName;
		if (getFullPath(fullClassName.replace('.', '/') + ".hx") != null)
		{
			return fullClassName;
		}
		return null;
	}
	
	function getGlobalClassName(shortClassName:String)
	{
		var localClassName = getLocalClassName(shortClassName);
		if (localClassName != null)
		{
			return localClassName;
		}
		
		var parentParser = getParentParser();
		if (parentParser != null)
		{
			return cast(parentParser, HaqTemplateParser).getGlobalClassName(shortClassName);
		}
		
		return null;
	}
	
	public function getServerClassName()
	{
		var r = getGlobalClassName("Server");
		return r != null && r != "" 
			? r 
			: (fullTag.startsWith("pages.") ? "haquery.server.HaqPage" : "haquery.server.HaqComponent");
	}
	
	public function getClientClassName()
	{
		var r = getGlobalClassName("Client");
		return r != null && r != ""  
			? r 
			: (fullTag.startsWith("pages.") ? "haquery.client.HaqPage" : "haquery.client.HaqComponent");
	}
	
	public function hasLocalServerClass() : Bool
	{
		return getLocalClassName("Server") != null;
	}
	
	public function hasLocalClientClass() : Bool
	{
		return getLocalClassName("Client") != null;
	}
	
	public function getGenFolder() : String
	{
		return "gen/" + fullTag.replace('.', '/') + "/";
	}
	
	public function getLastMod() : Date
	{
		var r = MIN_DATE;
		
		var localPath = fullTag.replace(".", "/");
		
		for (file in [ "template.html", "Server.hx", "Client.hx", HaqDefines.folders.support ])
		{
			var path = getFullPath(localPath + "/" + file);
			if (path != null)
			{
				r = maxDate(r, FileSystem.stat(path).mtime);
			}
		}
		
		r = maxDate(r, getConfigLastMod(localPath));
		
		var parentParser = getParentParser();
		if (parentParser != null)
		{
			r = maxDate(r, cast(parentParser, HaqTemplateParser).getLastMod());
			r = maxDate(r, getConfigLastMod(parentParser.fullTag.replace(".", "/")));
		}
		
		return r;
	}
	
	function getConfigLastMod(localPath:String) : Date
	{
		if (localPath == null || localPath == "") return MIN_DATE;
		
		var configPath = getFullPath(localPath + '/config.xml');
		var lastMod = configPath != null ? FileSystem.stat(configPath).mtime : MIN_DATE;
		
		var parts = localPath.split('/');
		if (parts.length <= 1) return lastMod;
		
		return maxDate(lastMod, getConfigLastMod(parts.slice(0, parts.length - 1).join('/')));
	}
	
	function maxDate(a:Date, b:Date) : Date 
	{
		return a.getTime() > b.getTime() ? a : b;
	}
	
	public function getRequires() : Array<String>
	{
		return cast(config, HaqTemplateConfig).requires;
	}
	
	public function getBaseServerClass() : String
	{
		var parentParser : HaqTemplateParser = cast getParentParser();
		return parentParser != null 
			? parentParser.getServerClassName() 
			: (fullTag.startsWith("pages.") ? "haquery.server.HaqPage" : "haquery.server.HaqComponent");
	}	
	
	public function getBaseClientClass() : String
	{
		var parentParser : HaqTemplateParser = cast getParentParser();
		return parentParser != null 
			? parentParser.getClientClassName() 
			: (fullTag.startsWith("pages.") ? "haquery.client.HaqPage" : "haquery.client.HaqComponent");
	}
}
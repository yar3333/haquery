package haquery.tools;

import haquery.server.FileSystem;
import haquery.server.io.File;
import haquery.server.HaqDefines;

import haquery.base.HaqTemplateParser.HaqTemplateNotFoundException;

using StringTools;

class HaqTemplateParser extends haquery.server.HaqTemplateParser
{
	static inline var MIN_DATE = new Date(2000, 0, 0, 0, 0, 0);
	
	var classPaths : Array<String>;
	
	public function new(classPaths:Array<String>, fullTag:String)
	{
		this.classPaths = classPaths;
		super(fullTag);
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
		try
		{
			return new HaqTemplateParser(classPaths, config.extend);
		}
		catch (e:HaqTemplateNotFoundException)
		{
			return null;
		}
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
		return r != null && r != "" ? r : "haquery.server.HaqComponent";
	}
	
	public function getClientClassName()
	{
		var r = getGlobalClassName("Client");
		return r != null && r != ""  ? r : "haquery.client.HaqComponent";
	}
	
	public function getDocLastMod() : Date
	{
		var docFilePath = getFullPath(fullTag.replace(".", "/") + "/template.html");
		var lastMod = docFilePath != null ? FileSystem.stat(docFilePath).mtime : MIN_DATE;
		var parentParser = getParentParser();
		if (parentParser != null)
		{
			var parentDocLastMod = cast(parentParser, HaqTemplateParser).getDocLastMod();
			if (parentDocLastMod.getTime() > lastMod.getTime())
			{
				lastMod = parentDocLastMod;
			}
		}
		return lastMod;
	}
	
	public function hasLocalServerClass() : Bool
	{
		return getLocalClassName("Server") != null;
	}
	
	public function hasLocalClientClass() : Bool
	{
		return getLocalClassName("Client") != null;
	}
	
	public function getTrmFilePath() : String
	{
		return getFullPath(fullTag.replace('.', '/')) + "/Template.hx";
	}
}
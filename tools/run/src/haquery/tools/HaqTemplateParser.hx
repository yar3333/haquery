package haquery.tools;

import haquery.server.FileSystem;
import haquery.server.io.File;
import haquery.server.HaqDefines;

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
	
	override function getFullPath(path:String)
	{
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
	
	public inline function getExtend()
	{
		return config.extend;
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
	
	function getClassName(shortClassName:String)
	{
		var localClassName = getLocalClassName(shortClassName);
		if (localClassName != null)
		{
			return localClassName;
		}
		
		if (config.extend != null && config.extend != "")
		{
			return new HaqTemplateParser(classPaths, config.extend).getClassName(shortClassName);
		}
		
		return null;
	}
	
	public function getServerClassName()
	{
		var r = getClassName("Server");
		return r != null && r != "" ? r : "haquery.server.HaqComponent";
	}
	
	public function getClientClassName()
	{
		var r = getClassName("Client");
		return r != null && r != ""  ? r : "haquery.client.HaqComponent";
	}
	
	public function getTrmSuperClassName()
	{
		if (config.extend != null && config.extend != "")
		{
			return new HaqTemplateParser(classPaths, config.extend).getClassName("Template");
		}
		return null;
	}
	
	public function getDocTextAndLastMod() : { text:String, lastMod:Date }
	{
		var docFilePath = getFullPath(fullTag.replace(".", "/") + "/template.html");
		var text = docFilePath != null ? File.getContent(docFilePath) : "";
		var lastMod = docFilePath != null ? FileSystem.stat(docFilePath).mtime : MIN_DATE;
		if (config.extend != null && config.extend != "")
		{
			var parentDocTextAndLastMod = new HaqTemplateParser(classPaths, config.extend).getDocTextAndLastMod();
			text = parentDocTextAndLastMod.text + text;
			if (parentDocTextAndLastMod.lastMod.getTime() > lastMod.getTime())
			{
				lastMod = parentDocTextAndLastMod.lastMod;
			}
			
		}
		return { text:text, lastMod:lastMod };
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
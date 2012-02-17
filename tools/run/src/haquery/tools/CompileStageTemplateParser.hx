package haquery.tools;

import haquery.server.HaqTemplateParser;
import haquery.server.FileSystem;
import haquery.server.HaqDefines;

using StringTools;

class CompileStageTemplateParser extends HaqTemplateParser
{
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
	
	function getClassName(className:String)
	{
		var className = fullTag + "." + className;
		if (getFullPath(className.replace('.', '/') + ".hx") != null)
		{
			return className;
		}
		
		if (config.extend != null && config.extend != "")
		{
			return new CompileStageTemplateParser(classPaths, config.extend).getClassName(className);
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
	
	//public function getTemplate
}
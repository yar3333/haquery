package haquery.base;

#if !client
private typedef TemplateParser = haquery.server.HaqTemplateParser;
#else
private typedef TemplateParser = haquery.client.HaqTemplateParser;
#end

import haquery.common.HaqDefines;
import haquery.Exception;
using haquery.StringTools;

class HaqTemplateException extends Exception
{
	override function toString() return message
}

class HaqTemplateNotFoundException extends HaqTemplateException
{
}

class HaqTemplateNotFoundCriticalException extends HaqTemplateException
{
}

class HaqTemplateRecursiveExtendException extends HaqTemplateException
{
}

class HaqTemplateParser<TemplateConfig:HaqTemplateConfig>
{
	public var fullTag(default, null) : String;
	var config : TemplateConfig;
	
	public function new(fullTag:String)
	{
		if (fullTag == null || fullTag == "" || !isTemplateExist(fullTag))
		{
			throw new HaqTemplateNotFoundException("Component not found [ " + fullTag + " ].");
		}
		
		this.fullTag = fullTag;
		config = getConfig();
	}
	
	function isTemplateExist(fullTag:String) : Bool
	{
		throw new Exception("This method must be overriden.");
		return false;
	}
	
	function getParentParser() : TemplateParser
	{
		throw new Exception("This method must be overriden.");
		return null;
	}
	
	function isPage() : Bool
	{
		return fullTag.startsWith(HaqDefines.folders.pages);
	}
	
	function getShortClassName() : String
	{
		throw new Exception("This method must be overriden.");
		return null;
	}
	
	public function getClassName() : String
	{
		var className = fullTag + "." + getShortClassName();
		var clas = Type.resolveClass(className);
		if (clas != null)
		{
			return className;
		}
		
		var parentParser = getParentParser();
		if (parentParser != null)
		{
			return parentParser.getClassName();
		}
		
		#if !client
		return isPage() ? "haquery.server.HaqPage" : "haquery.server.HaqComponent";
		#elseif js
		return isPage() ? "haquery.client.HaqPage" : "haquery.client.HaqComponent";
		#end
	}
	
	function getConfig() : TemplateConfig
	{
		throw new Exception("This method must be overriden.");
		return null;
	}
	
	public function getImports() : Array<String>
	{
		return config.imports;
	}
}
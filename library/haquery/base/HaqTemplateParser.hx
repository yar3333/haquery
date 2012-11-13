package haquery.base;

#if !client
private typedef TemplateParser = haquery.server.HaqTemplateParser;
#else
private typedef TemplateParser = haquery.client.HaqTemplateParser;
#end

import haquery.common.HaqDefines;
import haquery.common.HaqTemplateExceptions;
using haquery.StringTools;

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
		return fullTag.startsWith(HaqDefines.folders.pages + ".") ? "haquery.server.HaqPage" : "haquery.server.HaqComponent";
		#elseif js
		return fullTag.startsWith(HaqDefines.folders.pages + ".") ? "haquery.client.HaqPage" : "haquery.client.HaqComponent";
		#end
	}
	
	function getConfig() : TemplateConfig
	{
		throw new Exception("This method must be overriden.");
		return null;
	}
}
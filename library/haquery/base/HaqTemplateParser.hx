package haquery.base;

#if (php || neko)
private typedef Component = haquery.server.HaqComponent;
private typedef Page = haquery.server.HaqPage;
private typedef TemplateParser = haquery.server.HaqTemplateParser;
#elseif js
private typedef Component = haquery.client.HaqComponent;
private typedef Page = haquery.client.HaqPage;
private typedef TemplateParser = haquery.client.HaqTemplateParser;
#end


using haquery.StringTools;

class HaqTemplateParser
{
	public var fullTag(default, null) : String;
	var config : HaqTemplateConfig;
	
	public function new(fullTag:String)
	{
		this.fullTag = fullTag;
		config = getConfig();
	}
	
	function getParentParser() : TemplateParser
	{
		return new TemplateParser(config.extend);
	}
	
	function isPage() : Bool
	{
		return fullTag.startsWith(HaqDefines.folders.pages.replace("/", "."));
	}
	
	function getShortClassName() : String
	{
		throw "This method must be overriden.";
		return null;
	}
	
	public function getClass() : Class<Component>
	{
		var className = fullTag + "." + getShortClassName();
		var clas = Type.resolveClass(className);
		if (clas != null)
		{
			return cast clas;
		}
		
		if (config.extend != null && config.extend != "")
		{
			return getParentParser().getClass();
		}
		
		return isPage() ? cast(Page, Component) : Component;
	}
	
	function getConfig() : HaqTemplateConfig
	{
		throw "This method must be overriden.";
		return null;
	}
	
	public function getImports() : Array<String>
	{
		return config.imports;
	}
}
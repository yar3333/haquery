package haquery.base;

#if (php || neko)
private typedef TemplateParser = haquery.server.HaqTemplateParser;
#elseif js
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
		return cast Type.createInstance(Type.getClass(this), [ config.extend ]);
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
	
	public function getClassName() : String
	{
		var className = fullTag + "." + getShortClassName();
		var clas = Type.resolveClass(className);
		if (clas != null)
		{
			return className;
		}
		
		if (config.extend != null && config.extend != "")
		{
			return getParentParser().getClassName();
		}
		
		#if (php || neko)
		return isPage() ? "haquery.server.HaqPage" : "haquery.server.HaqComponent";
		#elseif js
		return isPage() ? "haquery.client.HaqPage" : "haquery.client.HaqComponent";
		#end
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
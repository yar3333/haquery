package haquery.base;

#if (!tools)
	#if (php || neko)
		typedef Template = haquery.server.HaqTemplate
		typedef Page = haquery.server.HaqPage
	#elseif js
		typedef Template = haquery.client.HaqTemplate
		typedef Page = haquery.client.HaqPage
	#end
#else
	typedef Template = haquery.tools.HaqTemplate
#end

class HaqTemplateManager 
{
	public var templates(default, null) : Hash<Template>;
	
	public function new()
	{
		templates = new Hash<Template>();
	}
	
	public function getTemplate(fullTag:String) : Template
	{
		if (!templates.exists(fullTag))
		{
			templates.set(fullTag, parseTemplate(fullTag));
		}
		return templates.get(fullTag);
	}
	
	public function createPage(pageFullTag:String, pageAttr:Hash<String>) : Page
	{
		throw "Method must be overriden.";
		return null;
	}
	
	function parseTemplate(fullTag:String) : Template
	{
		throw "Method must be overriden.";
		return null;
	}
	
	public function findTemplate(parent:HaqComponent, tag:String) : Template
	{
		var packageName = getPackageByFullTag(parent.fullTag);
		
		var template = getTemplate(packageName + '.' + tag);
		if (template == null)
		{
			for (importPackage in getTemplate(parent.fullTag).imports)
			{
				template = getTemplate(importPackage + '.' + tag);
				if (template != null)
				{
					break;
				}
			}
		}
		
		return template;
	}
	
	function getPackageByFullTag(fullTag:String)
	{
		var n = fullTag.lastIndexOf('.');
		if (n >= 0)
		{
			return fullTag.substr(0, n);
		}
		return '';
	}
}
package haquery.base;
	
#if (php || neko)
typedef Page = haquery.server.HaqPage
#elseif js
typedef Page = haquery.client.HaqPage
#end

class HaqTemplateManager<Template:HaqTemplate>
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
	
	public function findTemplate(parentFullTag:String, tag:String) : Template
	{
		var packageName = getPackageByFullTag(parentFullTag);
		
		var template = getTemplate(packageName + '.' + tag);
		if (template == null)
		{
			for (importPackage in getTemplate(parentFullTag).imports)
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
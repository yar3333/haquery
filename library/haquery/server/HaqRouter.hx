package haquery.server;

#if server

import stdlib.Regex;
using stdlib.StringTools;

typedef HaqRoute = 
{
	var fullTag : String;
	var pageID : String;
}

class HaqRouter
{
	var pagesFolderPath : String;
	var manager : HaqTemplateManager;
	
	public function new(pagesFolderPath:String, manager:HaqTemplateManager)
	{
		this.pagesFolderPath = pagesFolderPath;
		this.manager = manager;
	}
	
	public function getRoute(url:String, urlRewriteRegex:Array<Regex>) : HaqRoute
	{
		if (url == null) url = "";
		
		url = url.trim("/");
		
		var orig = url;
		for (re in urlRewriteRegex)
		{
			url = re.apply(url);
			if (url != orig) break;
		}
		
		if (url.startsWith("index.") || url == "index" || url.endsWith("/index") || url.indexOf(".") >= 0)
		{
			throw new HaqPageNotFoundException(url);
		}
		
		var path = pagesFolderPath + "/" + (url != "" ? url : "index");
		
		return getRouteInner(url, path.replace("/", "."), null);
	}
	
	function getRouteInner(url:String, fullTag:String, pageID:String) : HaqRoute
	{
		var fullTagIndex = fullTag + ".index";
		if (isPageExist(fullTagIndex))
		{
			return { fullTag:fullTagIndex, pageID:pageID };
		}
		
		if (isPageExist(fullTag))
		{
			return { fullTag:fullTag, pageID:pageID };
		}
		
		var n = fullTag.lastIndexOf(".");
		if (n >= 0)
		{
			return getRouteInner(url, fullTag.substr(0, n), fullTag.substr(n + 1) + (pageID != null ? "/" + pageID : ""));
		}
		
		throw new HaqPageNotFoundException(url);
	}
	
    function isPageExist(fullTag:String) : Bool
	{
		try
		{
			var template = manager.get(fullTag);
			return template != null;
		}
		catch (e:haquery.common.HaqTemplateExceptions.HaqTemplateNotFoundException)
		{
			return false;
		}
	}
}

#end
package haquery.server;

#if server

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
	
	public function getRoute(url:String) : HaqRoute
	{
		if (url == null) url = "";
		
		url = url.trim("/");
		
		if (url.startsWith("index.") || url == "index" || url.endsWith("/index") || url.indexOf(".") >= 0)
		{
			throw new HaqPageNotFoundException();
		}
		
		var path = pagesFolderPath + "/" + (url != "" ? url : "index");
		
		return getRouteInner(path.replace("/", "."), null);
	}
	
	function getRouteInner(fullTag:String, pageID:String) : HaqRoute
	{
		trace("getRouteInner " + fullTag + " ," + pageID);
		
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
			return getRouteInner(fullTag.substr(0, n), fullTag.substr(n + 1) + (pageID != null ? "/" + pageID : null));
		}
		
		throw new HaqPageNotFoundException();
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
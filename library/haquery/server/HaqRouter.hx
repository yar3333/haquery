package haquery.server;

using stdlib.StringTools;

typedef HaqRoute =
{
	/**
	 * Package with Server/Client classes. For example: "pages.login".
	 */
	var fullTag : String;
	
	/**
	 * Path tail to store into `Page.pageID` variable.
	 */
	var pageID : String;
}

class HaqRouter
{
	var pagesDirectory : String;
	var manager : HaqTemplateManager;
	var config : HaqConfig;
	
	public function new(pagesDirectory:String, manager:HaqTemplateManager, config:HaqConfig)
	{
		this.pagesDirectory = pagesDirectory;
		this.manager = manager;
		this.config = config;
	}
	
	/**
	 * You can override this method in your custom Route class.
	 */
	public function getRoute(url:String) : HaqRoute
	{
		if (url == null) url = "";
		
		url = url.trim("/");
		
		if (url.startsWith("index.") || url == "index" || url.endsWith("/index") || url.indexOf(".") >= 0)
		{
			throw new HaqPageNotFoundException(url);
		}
		
		var path = pagesDirectory + "/" + (url != "" ? url : "index");
		
		return getRouteInner(url, path.replace("/", "."), null);
	}
	
	function getRouteInner(url:String, fullTag:String, pageID:String) : HaqRoute
	{
		var fullTagIndex = fullTag + ".index";
		if (manager.exist(fullTagIndex))
		{
			return { fullTag:fullTagIndex, pageID:pageID };
		}
		
		if (manager.exist(fullTag))
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
}

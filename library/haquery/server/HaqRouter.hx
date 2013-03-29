package haquery.server;

#if server

import stdlib.Exception;
import stdlib.FileSystem;
import haquery.common.HaqTemplateExceptions;
using stdlib.StringTools;

class HaqRouterException extends Exception
{
	public var code(default, null) : Int;
	
	public function new(code:Int)
	{
		super();
		this.code = code;
	}
}

typedef HaqRoute = 
{
	var path : String;
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
		
		url = url.trim('/');
		
		if (url == 'index.php' 
		 || url == 'index.n' 
		 || url == 'index' 
		 || url.endsWith('/index')
		) {
			throw new HaqRouterException(403);
		}
		
		if (url.indexOf(".") >= 0)
		{
			throw new HaqRouterException(404);
		}
		
		var path = pagesFolderPath + "/" + (url != "" ? url : "index");
		
		if (isPageExist(path + "/index"))
		{
			path += "/index";
		}
		
		var pageID : String = null;
		
		if (!isPageExist(path))
		{
			var p = path.split('/');
			pageID = p.pop();
			path = p.join('/');
		}
		
		if (!isPageExist(path))
		{
			path += '/index';
		}
		
		if (!isPageExist(path))
		{
			throw new HaqRouterException(404);
		}
		
		return { path:path, fullTag:path.replace("/", "."), pageID:pageID };
	}
	
    function isPageExist(path:String) : Bool
	{
		try
		{
			var template = manager.get(path.replace("/", "."));
			return template != null;
		}
		catch (e:HaqTemplateNotFoundException)
		{
			return false;
		}
	}
}

#end
package haquery.server;

import haquery.common.HaqDefines;
import haquery.Exception;
import haquery.server.FileSystem;
using haquery.StringTools;

class HaqRouterException extends Exception
{
	public var code(default, null) : Int;
	
	public function new(code:Int)
	{
		super();
		this.code = code;
	}
}

class HaqRouter
{
	public function new() {}
	
	public function getRoute(url:String) : { path:String, fullTag:String, pageID:String }
	{
		if (url == null) url = "";
		
		if (url == 'index.php' 
		 || url == 'index.n' 
		 || url == 'index' 
		 || url.endsWith('/index')
		 || url == 'index.php/' 
		 || url == 'index.n/' 
		 || url == 'index/' 
		 || url.endsWith('/index/')
		) {
			throw new HaqRouterException(403);
		}
		
		url = url.trim('/');
		if (url == '') url = 'index';
		var path = HaqDefines.folders.pages + '/' + url;
		
		var pageID : String = null;
		
		if (isPageExist(path + '/index'))
		{
			path = path + '/index';
		}
		
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
		path = path.trim('/') + '/';
		return FileSystem.exists(path + 'template.html') || Type.resolveClass(path.replace("/", ".") + "Server") != null;
	}
}
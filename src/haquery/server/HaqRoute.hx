package haquery.server;

import php.FileSystem;
import php.io.Path;
import php.Lib;
import php.Sys;
import php.Web;

enum HaqRouteType
{
	file;
	page;
}

class HaqRoute
{
	public var routeType(default,null) : HaqRouteType;
	public var path(default,null) : String;
	public var className(default,null) : String;
	public var pageID(default,null) : String;
	
	public function new(url:String) : Void
	{
		if (url == 'index.php' || url == 'index')
		{
			Web.redirect('/');
			php.Sys.exit(0);
		}
		
		if (url.endsWith('/index'))
		{
			Web.redirect(url.substr(0, url.length - ("/index").length));
			Sys.exit(0);
		}
		
		if (FileSystem.exists(url) && url.endsWith('.php'))
		{
			routeType = HaqRouteType.file;
			path = url;
		}
		else
		{

			url = url.trim('/');
			if (url == '') url = 'index';
			url = HaQuery.folders.pages + '/' + url;
			

			var pageID = null;
			
			if (!isPageExist(url))
			{
				var p = url.split('/');
				pageID = p.pop();
				url = p.join('/');
			}
			
			if (!isPageExist(url))
			{
				php.Web.setReturnCode(404);
				Sys.exit(0);
			}
			
			path = url;
			
			className = url.replace('/', '.') + '.Server';
			if (Type.resolveClass(className)==null) className = 'haquery.server.HaqPage';
		}
	}
	
    static function isPageExist(path:String) : Bool
	{
		path = path.trim('/') + '/';
		return (FileSystem.exists(path + 'template.html') || Type.resolveClass(path.replace('/', '.') + 'Server') != null);
	}
}
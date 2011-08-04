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
	public var pagePath(default,null) : String;
	public var className(default,null) : String;
	public var templatePath(default,null) : String;
	public var pageID(default,null) : String;
	
	public function new(path:String) : Void
	{
		if (path == 'index.php' || path == 'index')
		{
			Web.redirect('/');
			php.Sys.exit(0);
		}
		
		if (path.endsWith('/index'))
		{
			Web.redirect(path.substr(0, path.length - ("/index").length));
			Sys.exit(0);
		}
		
		if (FileSystem.exists(path) && path.endsWith('.php'))
		{
			routeType = HaqRouteType.file;
			pagePath = path;
		}
		else
		{

			path = path.trim('/');
			if (path == '') path = 'index';
			path = 'pages/' + path;
			

			var pageID = null;
			
			if (!isPageExist(path))
			{
				var p = path.split('/');
				pageID = p.pop();
				path = p.join('/');
			}
			
			if (!isPageExist(path))
			{
				php.Web.setReturnCode(404);
				Sys.exit(0);
			}
			
			pagePath = path;
			
			className = path.replace('/', '.') + '.Server';
			if (Type.resolveClass(className)==null) className = 'haquery.server.HaqPage';
			
			templatePath = FileSystem.exists(path + '/template.phtml') ? path + '/template.phtml' : null;
		}
	}
	
    static function isPageExist(path:String) : Bool
	{
		path = path.trim('/') + '/';
		return (FileSystem.exists(path + 'template.phtml') || Type.resolveClass(path.replace('/', '.') + 'Server') != null);
	}
}
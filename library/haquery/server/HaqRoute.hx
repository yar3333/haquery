package haquery.server;

import haquery.server.FileSystem;
import haquery.server.Lib;
import haquery.server.Sys;
import haquery.server.Web;

#if php
import php.io.Path;
#elseif neko
import neko.io.Path;
#end

using haquery.StringTools;

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
			Sys.exit(0);
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
			path = HaqDefines.folders.pages + '/' + url;
            
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
				Web.setReturnCode(404);
                Lib.print("<h1>File not found (404)</h1>");
				Sys.exit(0);
			}
			
			className = path.replace('/', '.') + '.Server';
			if (Type.resolveClass(className) == null)
            {
                className = 'haquery.server.HaqPage';
            }
		}
	}
	
    static function isPageExist(path:String) : Bool
	{
		path = path.trim('/') + '/';
		return (FileSystem.exists(path + 'template.html') || Type.resolveClass(path.replace('/', '.') + 'Server') != null);
	}
}
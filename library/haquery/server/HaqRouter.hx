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
	file(path:String);
	page(path:String, fullTag:String, pageID:String);
}

class HaqRouter
{
	public function new() {}
	
	public function getRoute(url:String) : HaqRouteType
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
			return HaqRouteType.file(url);
		}
		else
		{
			url = url.trim('/');
			if (url == '') url = 'index';
			var path = HaqDefines.folders.pages + '/' + url;
			
			var pageID = null;
            
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
			
			return HaqRouteType.page(path, path.replace("/", "."), pageID);
		}
	}
	
    function isPageExist(path:String) : Bool
	{
		path = path.trim('/') + '/';
		return FileSystem.exists(path + 'template.html') || FileSystem.exists(path + 'Server.hx') || FileSystem.exists(path + 'Client.hx');
	}
}
package haquery.server;

import haquery.server.FileSystem;

using haquery.StringTools;

enum HaqRoute
{
	file(path:String);
	page(path:String, fullTag:String, pageID:String);
	error(code:Int);
}

class HaqRouter
{
	public function new() {}
	
	public function getRoute(url:String) : HaqRoute
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
			return HaqRoute.error(403);
		}
		
		if (FileSystem.exists(url) && url.endsWith('.php'))
		{
			return HaqRoute.file(url);
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
				return HaqRoute.error(404);
			}
			
			return HaqRoute.page(path, path.replace("/", "."), pageID);
		}
	}
	
    function isPageExist(path:String) : Bool
	{
		path = path.trim('/') + '/';
		return FileSystem.exists(path + 'template.html') || Type.resolveClass(path.replace("/", ".") + "Server") != null;
	}
}
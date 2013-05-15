package haquery.server;

#if server

#if php
private typedef NativeLib = php.Lib;
typedef Web = php.Web;
#elseif neko
private typedef NativeLib = neko.Lib;
typedef Web = neko.Web;
#end

import haquery.common.HaqStorage;
import stdlib.Exception;
import haxe.io.Path;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.PosInfos;
import haquery.common.HaqDefines;
import haquery.server.HaqRouter;
import models.server.Page;
import stdlib.Std;
import stdlib.Profiler;
import stdlib.FileSystem;
import haquery.common.HaqMessageListenerAnswer;
using stdlib.StringTools;

class Lib
{
    public static var profiler(default, null) : Profiler;
	public static var manager(default, null) : HaqTemplateManager;
	public static var uploads(default, null) : HaqUploads;
    
	public static function run() : Void
    {
		#if neko
		Sys.setCwd(getCwd());
		#end

		haxe.Log.trace = callback(HaqTrace.log, _, getClientIP(), null, null, _);
		
		var config = HaqConfig.load("config.xml");
		uploads = new HaqUploads(HaqDefines.folders.temp + "/uploads", config.maxPostSize);
		
		try
        {
			haxe.Log.trace = callback(HaqTrace.log, _, getClientIP(), config.filterTracesByIP, null, _);
			
			try
			{
				if (manager == null)
				{
					manager = new HaqTemplateManager();
				}
				
				var uri = Web.getURI();
				trace(uri);
				if (uri.startsWith("/haquery-"))
				{
					HaqSystem.run(uri.trim("/"), config);
				}
				else
				{
					var route = new HaqRouter(HaqDefines.folders.pages, manager).getRoute(uri);
					
					var bootstraps = loadBootstraps(route.path, config);
					
					haxe.Log.trace = callback(HaqTrace.log, _, getClientIP(), config.filterTracesByIP, null, _);
					
					var request = getRequest(route, config);
					var response = runPage(request, route, bootstraps).response;
					
					if (response != null)
					{
						Web.setReturnCode(response.statusCode);
						response.responseHeaders.send();
						response.cookie.send();
						NativeLib.print(
							!request.isPostback 
								? response.content 
								: Serializer.run(HaqMessageListenerAnswer.CallSharedServerMethodAnswer(response.ajaxResponse, response.result))
						);
					}
				}
			}
			catch (e:HaqRouterException)
			{
				Web.setReturnCode(e.code);
				NativeLib.println("<h1>Error " + e.code + "</h1>");
			}
        }
		catch (e:Dynamic)
        {
			Exception.trace(e);
			Exception.rethrow(e);
        }
    }
	
	static function getRequest(route:HaqRoute, config:HaqConfig) : HaqRequest
	{
		var params = Web.getParams();
		var isPostback = params.get("HAQUERY_POSTBACK") != null;
		return new HaqRequest(
			  route.fullTag
			, route.pageID
			, isPostback
			, params
			, new HaqCookie()
			, new HaqRequestHeaders()
			, getClientIP()
			, Web.getURI()
			, getHttpHost()
			, Web.getParamsString()
			, config
			, isPostback ? Unserializer.run(params.get("HAQUERY_STORAGE")) : new HaqStorage()
		);
	}
	
	public static function runPage(request:HaqRequest, route:HaqRoute, bootstraps:Array<HaqBootstrap>) : { page:Page, response:HaqResponse }
	{
		profiler = new Profiler(request.config.enableProfiling);
		
		profiler.begin("HAQUERY");
			
			for (bootstrap in bootstraps)
			{
				bootstrap.start(request);
			}
			
			profiler.begin("page");
				trace("HAQUERY START page = " + route.fullTag +  ", HTTP_HOST = " + request.host + ", clientIP = " + request.clientIP + ", pageID = " + route.pageID);
				
				var page = manager.createPage(route.fullTag, Std.hash(request));
				
				haxe.Log.trace = callback(HaqTrace.log, _, page.clientIP, page.config.filterTracesByIP, page, _);
				
				page.forEachComponent("preInit", true);
				page.forEachComponent("init", false);
				
				var response = !request.isPostback
						 ? page.generateResponseOnRender()
						 : page.generateResponseOnPostback(
								  request.params.get('HAQUERY_COMPONENT')
								, request.params.get('HAQUERY_METHOD')
								, Unserializer.run(request.params.get('HAQUERY_PARAMS'))
								, "shared"
						   );
			profiler.end();
			
			bootstraps.reverse();
			for (i in 0...bootstraps.length)
			{
				bootstraps[bootstraps.length - i - 1].finish(page);
			}
		
		profiler.end();
		profiler.traceResults();	
			
		return { page:page, response:response };
	}
	
    /**
     * Load bootstrap files from current folder to relativePath.
     */
    public static function loadBootstraps(relativePath:String, config:HaqConfig) : Array<HaqBootstrap>
    {
        var bootstraps = [];
		
		var folders = StringTools.trim(relativePath, '/').split('/');
        for (i in 1...folders.length + 1)
        {
            var className = folders.slice(0, i).join('.') + '.Bootstrap';
			var clas = Type.resolveClass(className);
            if (clas != null)
            {
				try
				{
					var bootstrap = cast(Type.createInstance(clas, []), HaqBootstrap);
					bootstraps.push(bootstrap);
				}
				catch (e:Dynamic)
				{
					throw new Exception("Bootstrap '" + className + "' problem.", e);
				}
            }
        }
		
		return bootstraps;
    }
	
	public static function getCompilationDate() : Date
	{
		#if php
		var path = getCwd() + "/index.php";
		#elseif neko
		var path = getCwd() + "/index.n";
		#end
		
		if (FileSystem.exists(path))
		{
			return FileSystem.stat(path).mtime;
		}
		
		throw "File '" + Path.withoutDirectory(path) + "' not found.";
	}
	
	static function getClientIP() : String
	{
		var ip = Web.getClientHeader("X-Real-IP");
		return ip != null && ip != "" ? ip : Web.getClientIP();
	}
	
	static function getHttpHost() : String 
	{
		#if php
		return untyped __var__("_SERVER", "HTTP_HOST"); 
		#else
		return Web.getClientHeader("Host");
		#end
    }
	
	static function newPageSecret()
	{
		var chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
		var s = "";
		for (i in 1...20)
		{
			s += chars.charAt(Std.random(chars.length));
		}
		return s;
	}
	
	static function getCwd() { return Web.getCwd().replace("\\", "/").rtrim("/"); }
}

#end
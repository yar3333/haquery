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
import haxe.io.Path;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.PosInfos;
import haquery.common.HaqDefines;
import haquery.server.HaqRouter;
import haquery.server.HaqPage;
import stdlib.Std;
import stdlib.Exception;
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
		runPage(Web.getURI());
    }
	
	public static function runPage(uri:String)
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
			
			if (manager == null)
			{
				manager = new HaqTemplateManager();
			}
			
			if (uri.startsWith("/haquery-"))
			{
				HaqSystem.run(uri.trim("/"), config);
			}
			else
			{
				var route = new HaqRouter(HaqDefines.folders.pages, manager).getRoute(uri);
				
				haxe.Log.trace = callback(HaqTrace.log, _, getClientIP(), config.filterTracesByIP, null, _);
				
				var request = getRequest(route, config);
				var response = getResponse(request, route);
				
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
		catch (e:Dynamic)
        {
			trace("EXCEPTION: " + Exception.string(e));
			Exception.rethrow(e);
        }
	}
	
	static function getResponse(request:HaqRequest, route:HaqRoute) : HaqResponse
	{
		profiler = new Profiler(request.config.enableProfiling);
		
		profiler.begin("HAQUERY");
			
			profiler.begin("page");
				
				trace("HAQUERY START page = " + route.fullTag +  ", HTTP_HOST = " + request.host + ", clientIP = " + request.clientIP + ", pageID = " + route.pageID);
				
				var page = manager.createPage(route.fullTag, request);
				
				haxe.Log.trace = callback(HaqTrace.log, _, page.clientIP, page.config.filterTracesByIP, page, _);
				
				var response : HaqResponse = null;
				try
				{
					page.forEachComponent("preInit", true);
					
					page.forEachComponent("init", false);
					
					response = !request.isPostback
							 ? page.generateResponseOnRender()
							 : page.generateResponseOnPostback(
									  request.params.get('HAQUERY_COMPONENT')
									, request.params.get('HAQUERY_METHOD')
									, Unserializer.run(request.params.get('HAQUERY_PARAMS'))
									, "shared"
							   );
				}
				catch (e:Dynamic)
				{
					try page.dispose() catch (_:Dynamic) {}
					Exception.rethrow(e);
				}
				
				page.dispose();
				
			profiler.end();
			
		
		profiler.end();
		profiler.traceResults();	
			
		return response;
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
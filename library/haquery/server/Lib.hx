package haquery.server;

import haquery.common.HaqStorage;
import haxe.io.Path;
import haxe.Json;
import stdlib.Serializer;
import stdlib.Unserializer;
import haxe.PosInfos;
import haquery.common.HaqDefines;
import haquery.server.HaqRouter;
import haquery.server.HaqPage;
import haquery.server.HaqCache;
import stdlib.Std;
import stdlib.Exception;
import stdlib.FileSystem;
import haquery.common.HaqMessageListenerAnswer;
import sys.io.File;
using stdlib.StringTools;

class Lib
{
	public static var manager : HaqTemplateManager;
	public static var uploads(default, null) : HaqUploads;
	
	public static var cache(default, null) : HaqCache;
    
	public static function run() : Void
    {
		runPage(Web.getURI());
    }
	
	public static function runPage(uri:String)
	{
		#if neko
		Sys.setCwd(getCwd());
		#end

		haxe.Log.trace = HaqTrace.log.bind(_, getClientIP(), null, null, _);
		
		var config = HaqConfig.load("config.xml");
		
		if (cache == null)
		{
			cache = new HaqCache(config.cacheSize);
			/*if (config.logSystemCalls) */trace("HAQUERY new cache");
		}
		
		uploads = new HaqUploads(HaqDefines.folders.temp + "/uploads", config.maxPostSize);
		
		try
        {
			haxe.Log.trace = HaqTrace.log.bind(_, getClientIP(), config.filterTracesByIP, null, _);
			
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
				var route = new Router(HaqDefines.folders.pages, manager, config).getRoute(uri);
				
				haxe.Log.trace = HaqTrace.log.bind(_, getClientIP(), config.filterTracesByIP, null, _);
				
				var request = getRequest(route, config);
				var response = getResponse(request, route);
				
				if (response != null)
				{
					Web.setReturnCode(response.statusCode);
					response.responseHeaders.send();
					response.cookie.send();
					
					Sys.print(
						!request.isPostback
						? response.content
						: Serializer.run(HaqMessageListenerAnswer.CallSharedServerMethodAnswer(response.ajaxResponse, response.result), true)
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
		var response : HaqResponse = null;
		
		#if profiler
		Profiler.measure("getResponse", function()
		{
		#end
			trace("HAQUERY START page = " + route.fullTag +  ", HTTP_HOST = " + request.host + ", clientIP = " + request.clientIP + ", pageID = " + route.pageID);
			
			var page = manager.createPage(route.fullTag, request);
			
			haxe.Log.trace = HaqTrace.log.bind(_, page.clientIP, page.config.filterTracesByIP, page, _);
			
			try
			{
				page.callMethodForEach("preInit", true);
				
				page.callMethodForEach("init", false);
				
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
		#if profiler
		});
		#end
		
		#if profiler
		if (request.config.profilingLevel > 0)
		{
			var pageName = request.uri + (request.isPostback ? " - POSTBACK" : "");
			
			var profilerFolder = HaqDefines.folders.temp + "/profiler";
			var profilerBaseFileName = profilerFolder + "/" + DateTools.format(Date.now(), "%Y-%m-%d-%H-%M-%S");
			FileSystem.createDirectory(profilerFolder);
			File.saveContent(profilerBaseFileName + ".summary.txt", pageName + "\n" + Profiler.getSummaryGistogram(request.config.profilingResultsWidth));
			File.saveContent(profilerBaseFileName + ".nested.txt", pageName + "\n" + Profiler.getNestedGistogram(request.config.profilingResultsWidth));
			if (request.config.profilingLevel > 1)
			{
				File.saveContent(profilerBaseFileName + ".callstack.json", Json.stringify( { name:pageName, stack:Profiler.getCallStack() } ));
				File.saveContent(profilerBaseFileName + ".callstack-long.json", Json.stringify( { name:pageName, stack:Profiler.getCallStack(10) } ));
			}
		}
		#end
		
		return response;
	}
	
	static function getRequest(route:HaqRoute, config:HaqConfig) : HaqRequest
	{
		var params = new HaqParams(Web.getParams());
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
	
	static function getCwd()
	{
		var cwd = Web.getCwd();
		if (cwd == null || cwd == "") return ".";
		return cwd.replace("\\", "/").rtrim("/");
	}
}

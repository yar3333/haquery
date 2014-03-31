package haquery.server;

#if server

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
import stdlib.Profiler;
import stdlib.FileSystem;
import haquery.common.HaqMessageListenerAnswer;
import sys.io.File;
using stdlib.StringTools;

#if php
private typedef NativeLib = php.Lib;
typedef Web = php.Web;
#elseif neko
private typedef NativeLib = neko.Lib;
typedef Web = neko.Web;
#end

class Lib
{
    @:isVar public static var profiler(get, set) : Profiler;
	static function get_profiler() : Profiler
	{
		if (profiler == null) profiler = new Profiler(0);
		return profiler;
	}
	static function set_profiler(v) : Profiler return profiler = v;
	
	public static var manager : HaqTemplateManager;
	public static var uploads(default, null) : HaqUploads;
	
	public static var cache(default, null) = new HaqCache(0);
    
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
		
		cache.maxSize = config.cacheSize;
		
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
				var route = new HaqRouter(HaqDefines.folders.pages, manager).getRoute(uri);
				
				haxe.Log.trace = HaqTrace.log.bind(_, getClientIP(), config.filterTracesByIP, null, _);
				
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
		profiler = new Profiler(request.config.profilingLevel);
		
		var response : HaqResponse = null;
		
		profiler.measure("getResponse", function()
		{
			trace("HAQUERY START page = " + route.fullTag +  ", HTTP_HOST = " + request.host + ", clientIP = " + request.clientIP + ", pageID = " + route.pageID);
			
			var page = manager.createPage(route.fullTag, request);
			
			haxe.Log.trace = HaqTrace.log.bind(_, page.clientIP, page.config.filterTracesByIP, page, _);
			
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
		});
		
		if (request.config.profilingLevel > 0)
		{
			var profilerFolder = HaqDefines.folders.temp + "/profiler";
			var profilerBaseFileName = profilerFolder + "/" + DateTools.format(Date.now(), "%Y-%m-%d-%H-%M-%S");
			FileSystem.createDirectory(profilerFolder);
			File.saveContent(profilerBaseFileName + ".summary.txt", request.uri + "\n" + profiler.getGistogram(profiler.getSummaryResults(), request.config.profilingResultsWidth));
			File.saveContent(profilerBaseFileName + ".nested.txt", request.uri + "\n" + profiler.getGistogram(profiler.getNestedResults(), request.config.profilingResultsWidth));
			if (request.config.profilingLevel > 1)
			{
				File.saveContent(profilerBaseFileName + ".callstack.json", Json.stringify(profiler.getCallStack()));
			}
		}
		
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
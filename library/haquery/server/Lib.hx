package haquery.server;

#if php
private typedef NativeLib = php.Lib;
#elseif neko
private typedef NativeLib = neko.Lib;
#end

#if php
typedef Web = php.Web;
#elseif neko
typedef Web = neko.Web;
#end

import haquery.common.HaqMessageListenerAnswer;
import haquery.Exception;
import haxe.io.Path;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.PosInfos;
import haquery.common.HaqDefines;
import haquery.server.db.HaqDb;
import haquery.server.HaqRouter;
using haquery.StringTools;

class Lib
{
	public static var config(default, null) : HaqConfig;
    public static var profiler(default, null) : HaqProfiler;
	public static var db(default, null) : HaqDb;
	public static var manager(default, null) : HaqTemplateManager;
	public static var uploads(default, null) : HaqUploads;
    
    public static function run() : Void
    {
		haquery.macros.HaqBuild.preBuild();
		
		#if neko
		Sys.setCwd(getCwd());
		#end
		
		db = null;
		config = new HaqConfig("config.xml");
		uploads = new HaqUploads(HaqDefines.folders.temp + "/uploads", config.maxPostSize);
		
		try
        {
			haxe.Log.trace = function(v:Dynamic, ?pos:PosInfos) HaqTrace.global(v, pos);
			
			try
			{
				var route = new HaqRouter(HaqDefines.folders.pages).getRoute(!isCli() ? Web.getParams().get('route') : HaqCli.getURI());
				
				var bootstraps = loadBootstraps(route.path);
				
				if (route.pageID != null && route.pageID.startsWith("haquery-"))
				{
					HaqSystem.run(route.pageID);
				}
				else
				{
					var listener = getListenerToDispatchRequest();
					var request = getRequest(route);
					var response = listener != null
								 ? listener.makeRequest(request)
								 : runPage(request, route, bootstraps).response;
					
					if (db != null)
					{
						db.close();
					}
								 
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
			
			if (db != null)
			{
				db.close();
			}
			
			Exception.rethrow(e);
        }
    }
	
	static function getListenerToDispatchRequest() : HaqWebsocketListener
	{
		if (config.listeners.iterator().hasNext())
		{
			var names = Lambda.array( { iterator:config.listeners.keys } );
			return config.listeners.get(names[Std.random(names.length)]);
		}
		return null;
	}
	
	static function getRequest(route:HaqRoute) : HaqRequest
	{
		var params = !isCli() ? Web.getParams() : HaqCli.getParams();
		return {
			  pageFullTag: route.fullTag
			, uri: !isCli() ? Web.getURI() : HaqCli.getURI()
			, pageID: route.pageID
			, isPostback: !isCli() && params.get('HAQUERY_POSTBACK') != null
			, params: params
			, cookie: new HaqCookie()
			, requestHeaders: new HaqRequestHeaders()
			, clientIP: getClientIP()
			, host: getHttpHost()
			, queryString: getParamsString()
			, pageKey: !isCli() && params.get('HAQUERY_PAGE_KEY') != null ? params.get('HAQUERY_PAGE_KEY') : Uuid.newUuid()
			, pageSecret: !isCli() && params.get('HAQUERY_PAGE_SECRET') != null ? params.get('HAQUERY_PAGE_SECRET') : newPageSecret()
		};
	}
	
	public static function runPage(request:HaqRequest, route:HaqRoute, bootstraps:Array<HaqBootstrap>) : { page:HaqPage, response:HaqResponse, config:HaqConfig, db:HaqDb }
	{
		profiler = new HaqProfiler(config.enableProfiling);
		
		var page : HaqPage;
		var response : HaqResponse;
		
		var r = pageContext(null, request.clientIP, Reflect.copy(config), null, function()
		{
			profiler.begin("HAQUERY");
			
				for (bootstrap in bootstraps)
				{
					bootstrap.init(request);
				}
			
				if (config.databaseConnectionString != null && config.databaseConnectionString != "")
				{
					db = new HaqDb(config.databaseConnectionString, config.sqlLogLevel, profiler);
				}
				
				for (bootstrap in bootstraps)
				{
					bootstrap.start();
				}
				
				if (manager == null)
				{
					profiler.begin('manager');
						manager = new HaqTemplateManager();
					profiler.end();
				}
				
				profiler.begin("page");
					trace("HAQUERY START " + (isCli() ? "CLI" : "WEB") + " pageFullTag = " + route.fullTag +  ", HTTP_HOST = " + getHttpHost() + ", clientIP = " + getClientIP() + ", pageID = " + route.pageID);
					
					page = manager.createPage(route.fullTag, Std.hash(request));
					
					pageContext(page, page.clientIP, Lib.config, Lib.db, function()
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
					});
				profiler.end();
				
				bootstraps.reverse();
				for (i in 0...bootstraps.length)
				{
					bootstraps[bootstraps.length - i - 1].finish(page);
				}
			
			profiler.end();
			profiler.traceResults();	
		});
			
		return { page:page, response:response, config:r.config, db:r.db };
	}
	
	public static function pageContext(page:HaqPage, clientIP:String, config:HaqConfig, db:HaqDb, f:Void->Void) : { config:HaqConfig, db:HaqDb }
	{
		var oldTrace = haxe.Log.trace;
		haxe.Log.trace = function(v:Dynamic, ?pos:PosInfos) HaqTrace.page(page, clientIP, v, pos);
		
		var oldConfig = Lib.config;
		Lib.config = config;
		
		var oldDb = Lib.db;
		Lib.db = db;
		
		try
		{
			f();
		}
		catch (e:Dynamic)
		{
			Exception.trace(e);
		}
		
		var r = { config:Lib.config, db:Lib.db };
		
		Lib.db = oldDb;
		Lib.config = oldConfig;
		haxe.Log.trace = oldTrace;
		
		return r;
	}
	
	#if debug
		public static function assert(e:Bool, errorMessage:String=null, ?pos:haxe.PosInfos) : Void
		{
			if (!e) 
			{
				if (errorMessage == null) errorMessage = "";
				throw "HAQUERY ASSERT " + errorMessage + " in " + pos.fileName + " at line " + pos.lineNumber;
			}
		}
	#else
		public static inline function assert(e:Bool, errorMessage:String=null, ?pos:haxe.PosInfos) : Void
		{
		}
	#end
	
    
    /**
     * Load bootstrap files from current folder to relativePath.
     */
    public static function loadBootstraps(relativePath:String) : Array<HaqBootstrap>
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
		
		throw "File '" + Path.withoutDirectory(path) + "' is not found.";
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
	
    static function getParamsString()
    {
        var s = Web.getParamsString();
        var re = ~/route=[^&]*/g;
        s = re.replace(s, '');
        return haquery.StringTools.trim(s, '&');
    }
	
	public static function isCli() : Bool
	{
		#if php
		return untyped __php__("PHP_SAPI == 'cli'");
		#elseif neko
		return !neko.Web.isModNeko && !neko.Web.isTora;
		#end
	}
	
	static function getCwd() { return Web.getCwd().replace("\\", "/").rtrim("/"); }
}

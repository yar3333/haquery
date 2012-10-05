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

import haquery.Exception;
import haxe.io.Bytes;
import haxe.io.Path;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.PosInfos;
import haquery.common.HaqDefines;
import haquery.server.db.HaqDb;
import haquery.server.HaqRouter;
import haquery.server.HaqUploadedFile.HaqUploadError;
import sys.io.File;
using haquery.StringTools;

class Lib
{
	public static var config : HaqConfig;
    public static var profiler : HaqProfiler;
	public static var db : HaqDb;
    
	public static var manager : HaqTemplateManager;
	
	static var startTime : Float;
	
	public static var daemon(default, null) : HaqDaemon;
    
    public static function run() : Void
    {
		haquery.macros.HaqBuild.preBuild();
		
		#if neko
		Sys.setCwd(getCwd());
		#end
		
		db = null;
		config = new HaqConfig("config.xml");
		
		try
        {
			startTime = Sys.time();
			haxe.Log.trace = function(v:Dynamic, ?pos:PosInfos) HaqLog.globalTrace(startTime, v, pos);
			
			try
			{
				var route = new HaqRouter(HaqDefines.folders.pages).getRoute(!isCli() ? Web.getParams().get('route') : HaqCli.getUrl());
				
				var bootstraps = loadBootstraps(route.path);
				
				if (route.pageID != null && route.pageID.startsWith("haquery-"))
				{
					runSystemCommand(route);
				}
				else
				{
					var daemon = getDaemonToDispatch();
					var response = daemon != null
								 ? daemon.makeRequest(getRequest(route))
								 : runPage(getRequest(route), route, bootstraps).response;
					
					if (response != null)
					{
						Web.setReturnCode(response.statusCode);
						response.responseHeaders.send();
						response.cookie.send();
						NativeLib.print(response.content);
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
	
	static function getDaemonToDispatch() : HaqDaemon
	{
		if (config.daemons.iterator().hasNext())
		{
			var names = Lambda.array( { iterator:config.daemons.keys } );
			return config.daemons.get(names[Std.random(names.length)]);
		}
		return null;
	}
	
	static function getRequest(route:HaqRoute) : HaqRequest
	{
		var params = !isCli() ? Web.getParams() : HaqCli.getParams();
		return {
			  pageFullTag: route.fullTag
			, uri: Web.getURI()
			, pageID: route.pageID
			, isPostback: !isCli() && Web.getParams().get('HAQUERY_POSTBACK') != null
			, params: params
			, cookie: new HaqCookie()
			, requestHeaders: new HaqRequestHeaders()
			, uploadedFiles: getUploadedFiles(params)
			, clientIP: getClientIP()
			, host: getHttpHost()
			, queryString: getParamsString()
			, pageUuid: Uuid.newUuid()
		};
	}
	
	public static function runPage(request:HaqRequest, route:HaqRoute, bootstraps:Array<HaqBootstrap>) : { page:HaqPage, response:HaqResponse }
	{
		var startTime =  Sys.time();
		
		profiler = new HaqProfiler(config.enableProfiling);
		
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
				
				var page = manager.createPage(route.fullTag, Std.hash(request));
				var saveTrace = haxe.Log.trace;
				haxe.Log.trace = function(v:Dynamic, ?pos:PosInfos) HaqLog.pageTrace(startTime, page, v, pos);
				page.forEachComponent("preInit", true);
				page.forEachComponent("init", false);
				
				var response = !request.isPostback
					? page.generateResponseByRender()
					: page.generateResponseByCallSharedMethod(request.params.get('HAQUERY_COMPONENT'), request.params.get('HAQUERY_METHOD'), Unserializer.run(request.params.get('HAQUERY_PARAMS')));
				
				haxe.Log.trace = saveTrace;
			profiler.end();
			
			bootstraps.reverse();
			for (bootstrap in bootstraps)
			{
				bootstrap.finish(page);
			}
			
			if (db != null)
			{
				db.close();
			}
		
		profiler.end();
		profiler.traceResults();	
		
		return { page:page, response:response };
	}
	
	static function runSystemCommand(route:HaqRoute)
	{
		switch (route.pageID)
		{
			case "haquery-flush":
				NativeLib.println("<b>HAQUERY FLUSH</b><br /><br />");
				var path = HaqDefines.folders.temp;
				
				NativeLib.println("delete '" + path + "/haquery.log" + "'<br />");
				FileSystem.deleteFile(path + "/haquery.log");
				
				NativeLib.println("delete '" + path + "/cache" + "'<br />");
				FileSystem.deleteDirectory(path + "/cache");
				
				NativeLib.println("delete '" + path + "/templates" + "'<br />");
				FileSystem.deleteDirectory(path + "/templates");
				
			case "haquery-daemon":
				if (isCli())
				{
					var args = Sys.args();
					if (args.length >= 3)
					{
						if (config.daemons.exists(args[1]))
						{
							switch (args[2])
							{
								case "run":		runDaemon(args[1]);
								case "start":	startDaemon(args[1]);
								case "stop":	stopDaemon(args[1]);
								
								default:
									NativeLib.println("Unknow <daemon_command>. Supported: 'run', 'start' and 'stop'.");
							}
						}
						else
						{
							NativeLib.println("Daemon '" + args[1] + "' is not found.");
						}
					}
					else
					{
						NativeLib.println("Need arguments: <daemon_name> and <daemon_command>.");
					}
				}
				else
				{
					NativeLib.println("This command allowed from the command-line only.");
				}
			
			default:
				NativeLib.println("HAQUERY ERROR: system command '" + route.pageID + "' is not supported.");
		}
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
		var realIP = Web.getClientHeader("X-Real-IP");
		return realIP != null && realIP != "" ? realIP : Web.getClientIP();
	}
	
	static function getHttpHost() : String 
	{
		#if php
		return untyped __var__("_SERVER", "HTTP_HOST"); 
		#else
		return Web.getClientHeader("Host");
		#end
    }
	
	static function getUploadedFiles(params:Hash<String>) : Hash<HaqUploadedFile>
	{
		var uploadedFiles = new Hash<HaqUploadedFile>();
		
		if (!isCli())
		{
			#if php
			
			var nativeFiles : Hash<php.NativeArray> = php.Lib.hashOfAssociativeArray(untyped __var__("_FILES"));
			for (id in nativeFiles.keys())
			{
				var file : php.NativeArray = nativeFiles.get(id);
				uploadedFiles.set(id, new HaqUploadedFile(
					 file[untyped "tmp_name"]
					,file[untyped "name"]
					,file[untyped "size"]
					,Type.createEnumIndex(HaqUploadError, file[untyped "error"])
				));
			}
			
			#elseif neko
			
			var lastPartName : String = null;
			var lastFileName : String = null;
			var lastTempFileName : String = null;
			var lastParamValue : String = null;
			var error : HaqUploadError = null;
			
			var maxUploadDataSize = config.maxPostSize;
			
			Web.parseMultipart(
				function(partName:String, fileName:String)
				{
					if (partName != lastPartName)
					{
						if (lastPartName != null)
						{
							if (lastFileName != null)
							{
								trace("set = " + lastPartName + ", " + lastFileName);
								uploadedFiles.set(
									lastPartName
								   ,new HaqUploadedFile(lastTempFileName, lastFileName, FileSystem.stat(lastTempFileName).size, error)
								);
							}
							else
							{
								params.set(lastPartName, lastParamValue);
							}
						}
						
						lastPartName = partName;
						lastFileName = fileName;
						lastTempFileName = getTempUploadedFilePath();
						lastParamValue = "";
						error = HaqUploadError.OK;
					}
				}
			   ,function(data:Bytes, offset:Int, length:Int)
				{
					if (lastFileName != null)
					{
						maxUploadDataSize -= length;
						if (maxUploadDataSize >= 0)
						{
							var h = File.append(lastTempFileName);
							h.writeBytes(data, 0, length);
							h.close();
						}
						else
						{
							error = HaqUploadError.INI_SIZE;
							if (FileSystem.exists(lastTempFileName))
							{
								FileSystem.deleteFile(lastTempFileName);
							}
						}
					}
					else
					{
						lastParamValue += data.readString(0, length);
					}
				}
			);
			
			if (lastPartName != null)
			{
				if (lastFileName != null)
				{
					uploadedFiles.set(
						lastPartName
					   ,new HaqUploadedFile(lastTempFileName, lastFileName, FileSystem.stat(lastTempFileName).size, error)
					);
				}
				else
				{
					params.set(lastPartName, lastParamValue);
				}
			}
			
			#end
		}
		
		return uploadedFiles;
	}
	
	static function getTempUploadedFilePath()
	{
		var s = Std.string(Sys.time() * 1000);
		if (s.indexOf(".") >= 0) s = s.substr(0, s.indexOf("."));
		s += "_" + Std.int(Math.random() * 999999);
		s += "_" + Std.int(Math.random() * 999999);
		
		var tempDir = getCwd() + "/" + HaqDefines.folders.temp;
		if (!FileSystem.exists(tempDir))
		{
			FileSystem.createDirectory(tempDir);
		}
		
		var uploadsDir = tempDir + "/uploads";
		if (!FileSystem.exists(uploadsDir))
		{
			FileSystem.createDirectory(uploadsDir);
		}
		
		return uploadsDir + "/" + s;
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
	
	static function runDaemon(name:String)
	{
		daemon = config.daemons.get(name);
		daemon.run();
	}
	
	static function startDaemon(name:String)
	{
		var p = new sys.io.Process("neko", [ "index.n", "haquery-daemon", name, "run" ]);
		NativeLib.println("Daemon '" + name + "' PID: " + p.getPid());
	}
	
	static function stopDaemon(name:String)
	{
	}
}

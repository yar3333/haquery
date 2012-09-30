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
import haxe.Stack;
import haxe.FirePHP;
import haxe.Serializer;
import haxe.Unserializer;
import haquery.common.HaqDumper;
import haquery.common.HaqDefines;
import haquery.server.db.HaqDb;
import haquery.server.FileSystem;
import haquery.server.HaqConfig;
import haquery.server.HaqCookie;
import haquery.server.HaqRouter;
import haquery.server.HaqProfiler;
import haquery.server.HaqUploadedFile.HaqUploadError;
import sys.io.FileOutput;
import sys.io.File;
using haquery.StringTools;

class Lib
{
	public static var config : HaqConfig;
    public static var profiler : HaqProfiler;
	public static var db : HaqDb;
	public static var isRedirected : Bool;
    public static var isHeadersSent(default, null) : Bool;
    
	static var manager : HaqTemplateManager;
	
	static var startTime : Float;
    
    public static function run() : Void
    {
		haquery.macros.HaqBuild.preBuild();
		
		isRedirected = false;
		isHeadersSent = false;
		db = null;
		
		#if neko
		Sys.setCwd(getCwd());
		#end
		
		config = new HaqConfig("config.xml");
		
		try
        {
			startTime = Sys.time();
			haxe.Log.trace = Lib.trace;
			
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
					runApplicationPage(route, bootstraps);
				}
			}
			catch (e:HaqRouterException)
			{
				setReturnCode(e.code);
				println("<h1>Error " + e.code + "</h1>");
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
	
	static function runApplicationPage(route:HaqRoute, bootstraps:Array<HaqBootstrap>) : Void
	{
		profiler = new HaqProfiler(config.enableProfiling);
		
		profiler.begin("HAQUERY");
		
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
			
			var isPostback = !isCli() && Web.getParams().get('HAQUERY_POSTBACK') != null;
			var params = !isCli() ? Web.getParams() : HaqCli.getParams();
			
			profiler.begin("page");
				trace("HAQUERY START " + (isCli() ? "CLI" : "WEB") + " pageFullTag = " + route.fullTag +  ", HTTP_HOST = " + getHttpHost() + ", clientIP = " + getClientIP() + ", pageID = " + route.pageID);
				
				var request : HaqRequest = {
					  uri: Web.getURI()
					, pageID: route.pageID
					, isPostback: isPostback
					, params: params
					, cookie: new HaqCookie(isPostback)
					, headers: new HaqHeaders(isPostback)
					, uploadedFiles: getUploadedFiles(params)
					, clientIP : getClientIP()
				};
				var page = manager.createPage(route.fullTag, Std.hash(request));
				
				if (!isPostback)
				{
					var html = page.render();
					trace("HAQUERY FINISH");
					if (!isRedirected)
					{
						Web.setHeader('Content-Type', page.contentType);
						print(html);
					}
				}
				else
				{
					page.forEachComponent('preEventHandlers');
					var componentID = params.get('HAQUERY_COMPONENT');
					var component = page.findComponent(componentID);
					if (component != null)
					{
						var result = HaqComponentTools.callMethod(component, params.get('HAQUERY_METHOD'), Unserializer.run(params.get('HAQUERY_PARAMS')));
						trace("HAQUERY FINISH");
						Web.setHeader('Content-Type', 'text/plain; charset=utf-8');
						print('HAQUERY_OK' + Serializer.run(result) + "\n" + page.ajaxResponse);
					}
					else
					{
						throw new Exception("Component id = '" + componentID + "' not found.");
					}
				}
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
	}
	
	static function runSystemCommand(route:HaqRoute)
	{
		switch (route.pageID)
		{
			case "haquery-flush":
				println("<b>HAQUERY FLUSH</b><br /><br />");
				var path = HaqDefines.folders.temp;
				
				println("delete '" + path + "/haquery.log" + "'<br />");
				FileSystem.deleteFile(path + "/haquery.log");
				
				println("delete '" + path + "/cache" + "'<br />");
				FileSystem.deleteDirectory(path + "/cache");
				
				println("delete '" + path + "/templates" + "'<br />");
				FileSystem.deleteDirectory(path + "/templates");
				
			default:
				println("HAQUERY ERROR: system command '" + route.pageID + "' is not supported.");
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
	
	static function trace(v:Dynamic, ?pos : haxe.PosInfos) : Void
    {
		if (config.filterTracesByIP != '')
        {
            if (config.filterTracesByIP != getClientIP()) return;
        }
        
        var text = '';
        if (Type.getClass(v) == String)
		{
			text += v;
		}
        else
        if (v != null)
        {
            text += "DUMP\n" + HaqDumper.getDump(v);
        }

		if (text != '' && !isCli())
        {
			if (!isHeadersSent)
            {
                try
                {
                    if (text.startsWith('EXCEPTION:'))
                    {
                        FirePHP.getInstance(true).error(text);
                    }
                    else if (text.startsWith('HAQUERY'))
                    {
                        FirePHP.getInstance(true).info(text);
                    }
                    else
                    {
                        text = pos.fileName + ":" + pos.lineNumber + " : " + text;
                        FirePHP.getInstance(true).warn(text);
                    }
                }
                catch (s:Dynamic)
                {
                    text += "\n\nFirePHP exception: " + s;
                }
            }
            else
            {
                // TODO: trace fix
				/*if (!isPostback)
				{
					NativeLib.println("<script>if (console) console.debug(decodeURIComponent(\"" + StringTools.urlEncode("SERVER " + text) + "\"));</script>");
				}*/
            }
        }
		
		if (!FileSystem.exists(HaqDefines.folders.temp))
        {
            FileSystem.createDirectory(HaqDefines.folders.temp);
        }
        
        var f : FileOutput = File.append(HaqDefines.folders.temp + "/haquery.log");
        if (f != null)
        {
			if (text != "")
			{
				var dt = Sys.time() - startTime;
				var duration = Math.floor(dt) + "." + Std.string(Math.floor((dt - Math.floor(dt)) * 1000)).lpad("0", 3);
				text = Date.fromTime(startTime * 1000) + " " + duration + " " +  StringTools.replace(text, "\n", "\r\n\t") + "\r\n";
			}
			else
			{
				text = "\r\n";
			}
			f.writeString(text);
            f.close();
        }
    }
    
    /**
     * Load bootstrap files from current folder to relativePath.
     */
    static function loadBootstraps(relativePath:String) : Array<HaqBootstrap>
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
	
	public static function getHttpHost() : String 
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
	
    public static function getParamsString()
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
	
	/*public*/ static function getCwd() { return Web.getCwd().replace("\\", "/").rtrim("/"); }
	
	//public static inline function setHeader(name:String, value:String) : Void { Web.setHeader(name, value); }	
	//public static inline function getClientHeader(name:String) : String { return Web.getClientHeader(name); }	
	/*public */static inline function getURI() : String { return Web.getURI();  }
	/*public */static inline function setReturnCode(status:Int) : Void { Web.setReturnCode(status); }
    /*public */static inline function print( v : Dynamic ) : Void { isHeadersSent = true; NativeLib.print(v); }
	/*public */static inline function println( v : Dynamic ) : Void { isHeadersSent = true; NativeLib.println(v); }
}

package haquery.server;

#if php
private typedef HaxeLib = php.Lib;
#elseif neko
private typedef HaxeLib = neko.Lib;
#elseif cpp
private typedef HaxeLib = cpp.Lib;
#end

#if php
typedef Web = php.Web;
#elseif neko
typedef Web = neko.Web;
#end

import haxe.io.Bytes;
import haxe.io.Path;
import haxe.Stack;
import haxe.FirePHP;
import haxe.Serializer;
import haxe.Unserializer;
import haquery.common.HaqCookie;
import haquery.common.HaqDumper;
import haquery.common.HaqDefines;
import haquery.server.db.HaqDb;
import haquery.server.FileSystem;
import haquery.server.cache.HaqCache;
import haquery.server.HaqConfig;
import haquery.server.HaqRouter;
import haquery.server.HaqProfiler;
import haquery.server.HaqUploadedFile.HaqUploadError;
import sys.io.FileOutput;
import sys.io.File;
using haquery.StringTools;

class Lib
{
	public static var config : HaqConfig;
	public static var cookie : HaqCookie;
    public static var profiler : HaqProfiler;
	public static var cache : HaqCache;
	public static var db : HaqDb;
	public static var isRedirected(default, null) : Bool;
    public static var isHeadersSent(default, null) : Bool;
	public static var page(default, null) : HaqPage;
	
    /**
     * Ajax ? calling server event handler : rendering HTML.
     */
    public static var isPostback(default, null) : Bool;
    
	static var params_cached : Hash<String>;
	public static var params(params_getter, null) : Hash<String>;
	
	static var uploadedFiles_cached : Hash<HaqUploadedFile>;
	public static var uploadedFiles(uploadedFiles_getter, null) : Hash<HaqUploadedFile>;
    
	static var manager : HaqTemplateManager;
	static var ajaxResponse : String;
	
	static var startTime : Float;
    
    public static function run() : Void
    {
		isRedirected = false;
		isHeadersSent = false;
		ajaxResponse = "";
		params_cached = null;
		uploadedFiles_cached = null;
		
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
				var route = new HaqRouter().getRoute(params.get('route'));
				
				cookie = new HaqCookie();
				
				var bootstraps = loadBootstraps(route.path);
				
				profiler = new HaqProfiler(config.enableProfiling);
				cache = new HaqCache(config.cacheConnectionString);
				
				profiler.begin("HAQUERY");
				
				if (config.databaseConnectionString != null && config.databaseConnectionString != "")
				{
					db = new HaqDb(config.databaseConnectionString, config.sqlLogLevel, profiler);
				}
				else
				{
					db = null;
				}
				
				isPostback = params.get('HAQUERY_POSTBACK') != null;
				
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
				
				if (route.pageID != null)
				{
					params.set("pageID", route.pageID);
				}
				
				profiler.begin("page");
					trace("HAQUERY START pageFullTag = " + route.fullTag +  ", HTTP_HOST = " + getHttpHost() + ", clientIP = " + getClientIP() + ", pageID = " + route.pageID);
					page = manager.createPage(route.fullTag, params);
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
							print('HAQUERY_OK' + Serializer.run(result) + "\n" + ajaxResponse);
						}
						else
						{
							throw "Component id = '" + componentID + "' not found.";
						}
					}
				profiler.end();
				
				bootstraps.reverse();
				for (bootstrap in bootstraps)
				{
					bootstrap.finish();
				}
				
				if (db != null)
				{
					db.close();
				}
				
				profiler.end();
				cache.dispose();
				profiler.traceResults();		
			}
			catch (e:HaqRouterException)
			{
				setReturnCode(e.code);
				println("<h1>Error " + e.code + "</h1>");
			}
        }
		catch (e:Dynamic)
        {
			traceException(e);
			if (db != null)
			{
				db.close();
			}
			if (cache != null)
			{
				cache.dispose();
			}
			throw e;
        }
    }
	
    public static function redirect(url:String) : Void
    {
        if (isPostback)
		{
			addAjaxResponse("haquery.client.Lib.redirect('" + url.addcslashes() + "');");
		}
        else
		{
			setReturnCode(302); // Moved Temporarily
			setHeader("Location", url);
			isRedirected = true;
		}
    }

	public static function reload() : Void
	{
        if (isPostback)
		{
			addAjaxResponse("window.location.reload(true);");
		}
        else
		{
			redirect(getURI());
		}
	}

	#if debug
		public static function assert(e:Bool, errorMessage:String=null, ?pos:haxe.PosInfos) : Void
		{
			if (!e) 
			{
				if (errorMessage == null) errorMessage = "HAQUERY ASSERT";
				throw errorMessage + " in " + pos.fileName + " at line " + pos.lineNumber;
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

		if (text != '')
        {
            if (!isHeadersSent)
            {
                try
                {
                    if (text.startsWith('HAXE EXCEPTION'))
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
                if (!isPostback)
				{
					HaxeLib.println("<script>if (console) console.debug(decodeURIComponent(\"" + StringTools.urlEncode("SERVER " + text) + "\"));</script>");
				}
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
					throw "Bootsrap '" + className + "' problem. " + e;
				}
            }
        }
		
		return bootstraps;
    }
    
    static function traceException(e:Dynamic) : Void
    {
        var text = "HAXE EXCEPTION: " + Std.string(e) + "\n"
                 + "Stack trace:" + Stack.toString(Stack.exceptionStack()).replace("\n", "\n\t");
        
		#if php		 
		var nativeStack : Array<Hash<Dynamic>> = php.Stack.nativeExceptionStack();
        if (nativeStack != null)
		{
			text += "\n\n";
			text += "NATIVE EXCEPTION: " + Std.string(e) + "\n";
			text += "Stack trace:\n";
			for (row in nativeStack)
			{
				text += "\t";
				if (row.exists('class')) text += row.get("class") + row.get("type");
				text += row.get('function');

				if (row.exists('file'))
				{
					text += " in " + row.get('file') + " at line " + row.get("line") + "\n";
				}
				else
				{
					text += "\n";
				}
			}
		}
		#end
		
        trace(text);
    }
	
	public static function getCompilationDate() : Date
	{
		var path = getCwd() + "/" + #if php "index.php" #elseif neko "index.n" #end;
		if (FileSystem.exists(path))
		{
			return FileSystem.stat(path).mtime;
		}
		
		throw "File '" + Path.withoutDirectory(path) + "' is not found.";
	}
	
	public static function getClientIP() : String
	{
		var realIP = getClientHeader("X-Real-IP");
		return realIP != null && realIP != "" ? realIP : Web.getClientIP();
	}
	
	public static function getHttpHost() : String 
	{
        #if php
		return untyped __var__("_SERVER", "HTTP_HOST"); 
		#else
		return getClientHeader("Host");
		#end
    }
	
	static function params_getter() : Hash<String>
	{
		if (params_cached == null)
		{
			fillParamsAndUploadedFiles();
		}
		return params_cached;
	}
	
	static function uploadedFiles_getter() : Hash<HaqUploadedFile>
	{
		if (uploadedFiles_cached == null)
		{
			fillParamsAndUploadedFiles();
		}
		return uploadedFiles_cached;
	}
	
	static function fillParamsAndUploadedFiles()
	{
		params_cached = Web.getParams();
		uploadedFiles_cached = new Hash<HaqUploadedFile>();
		
		#if php
		
		var nativeFiles : Hash<php.NativeArray> = php.Lib.hashOfAssociativeArray(untyped __var__("_FILES"));
		for (id in nativeFiles.keys())
		{
			var file : php.NativeArray = nativeFiles.get(id);
            uploadedFiles_cached.set(id, new HaqUploadedFile(
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
							uploadedFiles_cached.set(
								lastPartName
							   ,new HaqUploadedFile(lastTempFileName, lastFileName, FileSystem.stat(lastTempFileName).size, error)
							);
						}
						else
						{
							params_cached.set(lastPartName, lastParamValue);
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
				uploadedFiles_cached.set(
					lastPartName
				   ,new HaqUploadedFile(lastTempFileName, lastFileName, FileSystem.stat(lastTempFileName).size, error)
				);
			}
			else
			{
				params_cached.set(lastPartName, lastParamValue);
			}
		}
		
		#end
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
	
	public static inline function addAjaxResponse(jsCode:String) 
	{
		ajaxResponse += jsCode + "\n";
	}
	
    public static function getParamsString()
    {
        var s = Web.getParamsString();
        var re = ~/route=[^&]*/g;
        s = re.replace(s, '');
        return haquery.StringTools.trim(s, '&');
    }
	
	public static function getCwd() { return Web.getCwd().replace("\\", "/").rtrim("/"); }
	
	public static inline function setHeader(name:String, value:String) : Void { Web.setHeader(name, value); }	
	public static inline function getClientHeader(name:String) : String { return Web.getClientHeader(name); }	
	public static inline function getURI() : String { return Web.getURI();  }
	public static inline function setReturnCode(status:Int) : Void { Web.setReturnCode(status); }
    public static inline function print( v : Dynamic ) : Void { isHeadersSent = true; HaxeLib.print(v); }
	public static inline function println( v : Dynamic ) : Void { isHeadersSent = true; HaxeLib.println(v); }
}

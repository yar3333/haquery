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

import haxe.Stack;
import haxe.FirePHP;
import haquery.common.HaqCookie;
import haquery.common.HaqDefines;
import haquery.server.cache.HaqCache;
import haquery.server.db.HaqDb;
import haquery.server.FileSystem;
import haquery.server.HaqConfig;
import haquery.server.HaqRouter;
import haquery.server.HaqSystem;
import haquery.server.HaqProfiler;
import sys.io.FileOutput;
import sys.io.File;
import haquery.server.HaqUploadedFile.HaqUploadError;
import haxe.io.Bytes;

using haquery.StringTools;

class Lib
{
    public static var isHeadersSent(default, null) : Bool;
	
	public static var config : HaqConfig = null;
	public static var cookie : HaqCookie;
    public static var profiler : HaqProfiler = null;
	public static var cache : HaqCache = null;
	public static var db : HaqDb = null;
	public static var isRedirected = false;
	
    /**
     * Ajax ? calling server event handler : rendering HTML.
     */
    public static var isPostback(default, null) : Bool;
    
	static var params_cached : Hash<String>;
	public static var params(params_getter, null) : Hash<String>;
	
	static var uploadedFiles_cached : Hash<HaqUploadedFile>;
	public static var uploadedFiles(uploadedFiles_getter, null) : Hash<HaqUploadedFile>;
    
	static var startTime : Float;
    
    public static function getParamsString()
    {
        var s = Web.getParamsString();
        var re = ~/route=[^&]*/g;
        s = re.replace(s, '');
        return haquery.StringTools.trim(s, '&');
    }

    static public function run() : Void
    {
        #if neko
		Sys.setCwd(Web.getCwd());
		#end
		
		params_cached = null;
		uploadedFiles_cached = null;
		
		config = new HaqConfig("config.xml");
		
		try
        {
			startTime = Sys.time();
			haxe.Log.trace = Lib.trace;
			
			var router = new HaqRouter();
			var route = router.getRoute(Web.getParams().get('route'));
			
			switch (route)
			{
				case HaqRoute.file(path): 
				#if php
					untyped __call__('require', path);
				#elseif neko
					throw "HaqRoute.file is unsupported for neko platform.";
				#end
				
				case HaqRoute.page(path, fullTag, pageID): 
					cookie = new HaqCookie();
					
					loadBootstraps(path);
					
					profiler = new HaqProfiler(config.enableProfiling);
					cache = new HaqCache(config.cacheConnectionString);
					
					profiler.begin("HAQUERY");
					
					#if php
					php.Session.start();
					#end
					
					if (config.databaseConnectionString != null && config.databaseConnectionString != "")
					{
						db = new HaqDb(config.databaseConnectionString, config.sqlLogLevel, profiler);
					}
					
					isPostback = Web.getParams().get('HAQUERY_POSTBACK') != null;
					
					if (config.onStart != null)
					{
						config.onStart();
					}
					
					HaqSystem.run(fullTag, pageID, isPostback);
					
					if (config.onFinish != null)
					{
						config.onFinish();
					}
					
					profiler.end();
					cache.dispose();
					profiler.traceResults();		
					
				case HaqRoute.error(code): 
					Web.setReturnCode(code);
					Lib.println("<h1>Error " + code + "</h1>");
			}                
        }
		catch (e:Dynamic)
        {
			if (cache != null)
			{
				cache.dispose();
			}
			traceException(e);
			throw e;
        }
    }
	
    static public function redirect(url:String) : Void
    {
        if (Lib.isPostback)
		{
			HaqSystem.addAjaxResponse("haquery.client.Lib.redirect('" + StringTools.addcslashes(url) + "');");
		}
        else
		{
			Web.setReturnCode(302); // Moved Temporarily
			Web.setHeader("Location", url);
			isRedirected = true;
		}
    }

	static public function reload() : Void
	{
        if (Lib.isPostback)
		{
			HaqSystem.addAjaxResponse("window.location.reload(true);");
		}
        else
		{
			redirect(Web.getURI());
		}
	}

	#if debug
		static public function assert(e:Bool, errorMessage:String=null, ?pos:haxe.PosInfos) : Void
		{
			if (!e) 
			{
				if (errorMessage == null) errorMessage = "HAQUERY ASSERT";
				throw errorMessage + " in " + pos.fileName + " at line " + pos.lineNumber;
			}
		}
	#else
		static public inline function assert(e:Bool, errorMessage:String=null, ?pos:haxe.PosInfos) : Void
		{
		}
	#end
	
	static function trace(v:Dynamic, ?pos : haxe.PosInfos) : Void
    {
		if (Lib.config.filterTracesByIP != '')
        {
            if (Lib.config.filterTracesByIP != Web.getClientIP()) return;
        }
        
        var text = '';
        if (Type.getClass(v) == String)
		{
			text += v;
		}
        else
        if (v != null)
        {
            text += "DUMP\n" + getDump(v);
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
                HaxeLib.println("<script>if (console) console.debug(decodeURIComponent(\"" + StringTools.urlEncode("SERVER " + text) + "\"));</script>");
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
				var duration = formatTime(Sys.time() - startTime);
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
	
	static function getDump(v:Dynamic, level=0) : String
	{
		var prefix = ""; for (i in 0...level) prefix += "\t";
		
		var s : String;
		switch (Type.typeof(v))
		{
			case ValueType.TBool:
				s = "BOOL" + (v ? "true" : "false") + ")";
			
			case ValueType.TNull:
				s = "NULL";
				
			case ValueType.TClass(c):
				if (c == String)
				{
					s = "STRING(" + Std.string(v) + ")";
				}
				else
				if (c == Array)
				{
					s = "ARRAY(" + v.length + ")\n";
					for (item in cast(v, Array<Dynamic>))
					{
						s += getDump(item, level + 1);
					}
				}
				else
				if (c == Hash)
				{
					s = "HASH\n";
					for (key in cast(v, Hash<Dynamic>).keys())
					{
						s += prefix + key + " => " + getDump(v.get(key), level + 1);
					}
				}
				else
				{
					s = "CLASS(" + Type.getClassName(c) + ")\n" + getDumpObject(v, level + 1);
				}
			
			case ValueType.TEnum(e):
				s = "ENUM(" + Type.getEnumName(e) + ") = " + Type.enumConstructor(v);
			
			case ValueType.TFloat:
				s = "FLOAT(" + Std.string(v) + ")";
			
			case ValueType.TInt:
				s = "INT(" + Std.string(v) + ")";
			
			case ValueType.TObject:
				s = "OBJECT" + "\n" + getDumpObject(v, level + 1);
			
			case ValueType.TFunction, ValueType.TUnknown:
				s = "FUNCTION OR UNKNOW";
		};
		return s != "" ? s + "\n" : "";
	}
	
	static function getDumpObject(obj:Dynamic, level:Int) : String
	{
		var prefix = ""; for (i in 0...level) prefix += "\t";
		var s = "";
		for (fieldName in Reflect.fields(obj))
		{
			s += prefix + fieldName + " : " + getDump(Reflect.field(obj, fieldName), level);
		}
		return s;
	}
	
	static function formatTime(dt:Float) : String
	{
		#if php
		return StringTools.format("%.3f", dt);
		#else
		return Math.floor(dt) + "." + StringTools.lpad(Std.string(Math.floor((dt - Math.floor(dt)) * 1000)), "0", 3);
		#end
	}
    
    /**
     * Load bootstrap files from current folder to relativePath.
     */
    static function loadBootstraps(relativePath:String) : Void
    {
        var folders = StringTools.trim(relativePath, '/').split('/');
        for (i in 1...folders.length + 1)
        {
            var className = folders.slice(0, i).join('.') + '.Bootstrap';
			var clas = Type.resolveClass(className);
            if (clas != null)
            {
				var initMethod = Reflect.field(clas, "init");
				if (initMethod != null)
				{
					Reflect.callMethod(clas, initMethod, [ config ]);
				}
				else
				{
					throw "Bootsrap class " + className + " must have init() method.";
				}
            }
        }
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
	
	static public function mail(email:String, fromEmail:String, subject:String, message:String) : Bool
	{
		var headers : String = "MIME-Version: 1.0\r\n";
		headers += "Content-Type: text/plain; charset=utf-8\r\n";
		headers += "Date: " + Date.now() + "\r\n";
		headers += "From: " + fromEmail + "\r\n";
		headers += "X-Mailer: My Send E-mail\r\n";
		return untyped __call__("mail", email, subject, message, headers);
	}
	
	static public function getCompilationDate() : Date
	{
		var path = Web.getCwd() + "/" + #if php "index.php" #elseif neko "index.n" #end;
		if (FileSystem.exists(path))
		{
			return FileSystem.stat(path).mtime;
		}
		
		throw "File '" + file + "' is not found.";
	}
	
	public static function getClientIP() : String
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
		
		var nativeFiles : Hash<php.NativeArray> = Lib.hashOfAssociativeArray(untyped __var__("_FILES"));
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
		
		var maxUploadDataSize = Lib.config.maxPostSize;
		
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
		
		var tempDir = Web.getCwd() + "/" + HaqDefines.folders.temp;
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
	
	public static inline function setHeader(name:String, value:String) : Void { Web.setHeader(name, value); }	
	public static inline function getURI() : String { return Web.getURI();  }
	
    ////////////////////////////////////////////////
    // official methods
    ////////////////////////////////////////////////    
	/**
		Print the specified value on the default output.
	**/
    public static inline function print( v : Dynamic ) : Void { isHeadersSent = true; HaxeLib.print(v); }

	/**
		Print the specified value on the default output followed by a newline character.
	**/
	public static inline function println( v : Dynamic ) : Void { isHeadersSent = true; HaxeLib.println(v); }

	#if php
	public static inline function extensionLoaded(name : String) { return HaxeLib.extensionLoaded(name); }
	public static inline function isCli() : Bool { return HaxeLib.isCli(); }
	public static inline function printFile(file : String) : Void { isHeadersSent = true; HaxeLib.printFile(file); }
	
	public static inline function dump(v : Dynamic) : Void { isHeadersSent = true; HaxeLib.dump(v); }
	
	/**
		Serialize using native PHP serialization. This will return a Binary string that can be
		stored for long term usage.
	**/
	public static inline function serialize( v : Dynamic ) : String { return HaxeLib.serialize(v); }

	/**
		Unserialize a string using native PHP serialization. See [serialize].
	**/
	public static inline function unserialize( s : String ) : Dynamic { return HaxeLib.unserialize(s); }
	
	public static inline function toPhpArray(a : Array<Dynamic>) : php.NativeArray { return HaxeLib.toPhpArray(a); }
	public static inline function toHaxeArray(a : php.NativeArray) : Array<Dynamic> { return HaxeLib.toHaxeArray(a); }
	public static inline function hashOfAssociativeArray<T>(arr : php.NativeArray) : Hash<T> { return HaxeLib.hashOfAssociativeArray(arr); }
	public static inline function associativeArrayOfHash(hash : Hash<Dynamic>) : php.NativeArray { return HaxeLib.associativeArrayOfHash(hash); }
	
	/**
	*  Loads types defined in the specified directory.
 	*/
 	public static inline function loadLib(pathToLib : String) : Void { return HaxeLib.loadLib(pathToLib); }
	#end

	/**
		For neko compatibility only.
	**/
	public static inline function rethrow( e : Dynamic ) { return HaxeLib.rethrow(e); }

	public static inline function getClasses() { return HaxeLib.getClasses(); }
	
}

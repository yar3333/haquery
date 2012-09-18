package haquery.server;

#if php
private typedef HaxeLib = php.Lib;
#elseif neko
private typedef HaxeLib = neko.Lib;
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
import haquery.server.HaqRouter;
import haquery.server.HaqProfiler;
import haquery.server.HaqUploadedFile.HaqUploadError;
import sys.io.FileOutput;
import sys.io.File;
using haquery.StringTools;

class Lib
{
	public static var isRedirected(default, null) : Bool;
    public static var isHeadersSent(default, null) : Bool;
    
	static var manager : HaqTemplateManager;
	
    public static function run() : Void
    {
		haquery.macros.HaqBuild.preBuild();
		
		isRedirected = false;
		isHeadersSent = false;
		
		#if neko
		Sys.setCwd(getCwd());
		#end
		
		config = new HaqConfig("config.xml");
		
		try
        {
			haxe.Log.trace = Lib.trace;
			
			try
			{
				var route = new HaqRouter(HaqDefines.folders.pages).getRoute(!isCli() ? params.get('route') : HaqCli.getUrl());
				var bootstraps = loadBootstraps(route.path);
				if (route.pageID != null && route.pageID.startsWith("haquery-"))
				{
					runSystemCommand(route);
				}
				else
				{
					HaqPage.run(route, bootstraps);
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
			Exception.rethrow(e);
        }
	
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
	
	public static function getCwd() { return Web.getCwd().replace("\\", "/").rtrim("/"); }
	
	public static inline function setHeader(name:String, value:String) : Void { Web.setHeader(name, value); }	
	public static inline function getClientHeader(name:String) : String { return Web.getClientHeader(name); }	
	public static inline function getURI() : String { return Web.getURI();  }
	public static inline function setReturnCode(status:Int) : Void { Web.setReturnCode(status); }
    public static inline function print( v : Dynamic ) : Void { isHeadersSent = true; HaxeLib.print(v); }
	public static inline function println( v : Dynamic ) : Void { isHeadersSent = true; HaxeLib.println(v); }
}

package haquery.server;

import haquery.server.io.File;
import haxe.Stack;

#if php
private typedef HaxeLib = php.Lib;
#elseif neko
private typedef HaxeLib = neko.Lib;
#elseif cpp
private typedef HaxeLib = cpp.Lib;
#end

import haquery.server.HaqConfig;
import haquery.server.HaqRouter;
import haquery.server.HaqSystem;
import haquery.server.db.HaqDb;
import haquery.server.HaqProfiler;
import haquery.server.Web;
import haquery.server.FileSystem;
import haquery.server.io.FileOutput;
import haquery.server.io.File;

using haquery.StringTools;

class Lib
{
    public static var config = new HaqConfig();
    
    public static var profiler = new HaqProfiler();
	
	public static var isRedirected = false;
    
    /**
     * Ajax?
     *   false => rendering HTML;
     *   true => calling server event handler.
     */
    public static var isPostback(default, null) : Bool;
    
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
		
		try
        {
            profiler.begin("HAQUERY");
                startTime = Date.now().getTime();
				haxe.Log.trace = Lib.trace;
                
				isPostback = Web.getParams().get('HAQUERY_POSTBACK') != null;
                
				var router = new HaqRouter();
				var route = router.getRoute(Web.getParams().get('route'));

				switch (route)
				{
					case HaqRoute.file(path): 
						untyped __call__('require', path);
					
					case HaqRoute.page(path, fullTag, pageID): 
						loadBootstraps(path);
						
						#if php
						php.Session.start();
						#end
						
						if (config.databaseConnectionString != null && config.databaseConnectionString != "")
						{
							HaqDb.connect(config.databaseConnectionString);
						}
						
						if (config.onStart != null)
						{
							config.onStart();
						}
						
						HaqSystem.run(fullTag, pageID, isPostback);
						
						if (config.onFinish != null)
						{
							config.onFinish();
						}
				}                
            profiler.end();
            profiler.traceResults();
        }
        catch (e:Dynamic)
        {
            traceException(e);
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
			Web.setHeader('Location', url);
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
		static public function assert(e:Bool, errorMessage:String=null, ?pos : haxe.PosInfos) : Void
		{
			if (!e) 
			{
				if (errorMessage == null) errorMessage = "ASSERT";
				throw errorMessage + " in " + pos.fileName + ' at line ' + pos.lineNumber;
			}
		}
	#else
		static public inline function assert(e:Bool, errorMessage:String=null, ?pos : haxe.PosInfos) : Void
		{
		}
	#end
	
	static function trace(v:Dynamic, ?pos : haxe.PosInfos) : Void
    {
		if (Lib.config.filterTracesByIP != '')
        {
            if (Lib.config.filterTracesByIP != Web.getClientIP()) return;
        }
        
		#if php
        var text = '';
        if (Type.getClassName(Type.getClass(v)) == 'String') text += v;
        else
        if (v != null)
        {
            text += "DUMP\n";
            var dump = ''; untyped __php__("ob_start(); var_dump($v); $dump = ob_get_clean();");
            text += StringTools.stripTags(dump);
        }

		if (text != '')
        {
            var isHeadersSent : Bool = untyped __call__('headers_sent');
            if (!isHeadersSent)
            {
                try
                {
                    if (text.startsWith('HAXE EXCEPTION'))
                    {
                        php.FirePHP.getInstance(true).error(text);
                    }
                    else if (text.startsWith('HAQUERY'))
                    {
                        php.FirePHP.getInstance(true).info(text);
                    }
                    else
                    {
                        text = pos.fileName + ":" + pos.lineNumber + " : " + text;
                        php.FirePHP.getInstance(true).warn(text);
                    }
                }
                catch (s:String)
                {
                    text += "\n\nFirePHP exception: " + s;
                }
            }
            else
            {
                HaxeLib.println("<script>if (console) console.debug(decodeURIComponent(\"" + StringTools.urlEncode("SERVER " + text) + "\"));</script>");
            }
        }
		
		#else
		
		var text = Std.string(v != null ? v : "");
        
		#end
        
		if (!FileSystem.exists(HaqDefines.folders.temp))
        {
            FileSystem.createDirectory(HaqDefines.folders.temp);
        }
        
        var f : FileOutput = File.append(HaqDefines.folders.temp + "/haquery.log");
        if (f != null)
        {
			f.writeString(text != "" ? formatTime((Date.now().getTime() - startTime) / 1000.0) + " " +  StringTools.replace(text, "\n", "\r\n\t") + "\r\n" : "\r\n");
            f.close();
        }
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
                 + "Stack trace:" + Stack.toString(Stack.exceptionStack()).replace('\n', '\n\t');
        
		#if php		 
		var nativeStack : Array<Hash<Dynamic>> = php.Stack.nativeExceptionStack();
        assert(nativeStack != null);
        text += "\n\n";
        text += "NATIVE EXCEPTION: " + Std.string(e) + "\n";
        text += "Stack trace:\n";
        for (row in nativeStack)
        {
            text += "\t";
            if (row.exists('class')) text += row.get('class') + row.get('type');
            text += row.get('function');

            if (row.exists('file'))
            {
                text += " in " + row.get('file') + " at line " + row.get('line') + "\n";
            }
            else
            {
                text += "\n";
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
	
    ////////////////////////////////////////////////
    // official methods
    ////////////////////////////////////////////////    
	/**
		Print the specified value on the default output.
	**/
    public static inline function print( v : Dynamic ) : Void { return HaxeLib.print(v); }

	/**
		Print the specified value on the default output followed by a newline character.
	**/
	public static inline function println( v : Dynamic ) : Void { return HaxeLib.println(v); }

	#if php
	public static inline function extensionLoaded(name : String) { return HaxeLib.extensionLoaded(name); }
	public static inline function isCli() : Bool { return HaxeLib.isCli(); }
	public static inline function printFile(file : String) { return HaxeLib.printFile(file); }
	
	public static inline function dump(v : Dynamic) : Void { return HaxeLib.dump(v); }
	
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

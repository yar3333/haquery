package haquery.server;

import haxe.Stack;

import php.Sys;
import php.NativeArray;
import php.Session;
import php.FileSystem;
import php.io.FileOutput;
import php.io.Path;
import php.firePHP.FirePHP;
import haquery.server.HaqInternals;
import haquery.server.HaqConfig;
import haquery.server.HaqRoute;
import haquery.server.HaqBootstrap;
import haquery.server.HaqSystem;
import haquery.server.db.HaqDb;
import haquery.server.HaqProfiler;
import haquery.server.Web;

using haquery.StringTools;

class Lib
{
    public static var config = new HaqConfig();
    
    public static var profiler = new HaqProfiler();
    
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
        try
        {
            profiler.begin("HAQUERY");
        
                startTime = Date.now().getTime();
                haxe.Log.trace = Lib.trace;
                
                isPostback = php.Web.getParams().get('HAQUERY_POSTBACK') != null;
                
                var route = new HaqRoute(Web.getParams().get('route'));
                loadBootstraps(route.path);
                
                if (Lib.config.autoSessionStart)
                {
                    Session.start();
                }

                if (config.autoDatabaseConnect && config.db!=null && config.db.type!=null && config.db.type!="")
                {
                    HaqDb.connect(Lib.config.db);
                }
                
                if (route.routeType == HaqRouteType.file)
                {
                    untyped __call__('require', route.path);
                }
                else
                {
                    var system = new HaqSystem(route, isPostback);
                }
        
            profiler.end();
            profiler.traceResults();
        }
        catch (e:Dynamic)
        {
            haquery.server.Lib.traceException(e);
        }
    }
	
    static public function redirect(url:String) : Void
    {
        if (Lib.isPostback) HaqInternals.addAjaxResponse("haquery.client.Lib.redirect('" + StringTools.addcslashes(url) + "');");
        else                      php.Web.redirect(url);
    }

	static public function reload() : Void
	{
        if (Lib.isPostback) HaqInternals.addAjaxResponse("window.location.reload(true);");
        else					  redirect(php.Web.getURI());
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
            if (Lib.config.filterTracesByIP!=Web.getClientIP()) return;
        }
        
        var text = '';
        if (Type.getClassName(Type.getClass(v)) == 'String') text += v;
        else
        if (v!=null)
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
                catch (s:String)
                {
                    text += "\n\nFirePHP exception: " + s;
                }
            }
            else
            {
                php.Lib.println("<script>if (console) console.debug(decodeURIComponent(\"" + StringTools.urlEncode("SERVER " + text) + "\"));</script>");
            }
        }
        
        if (!FileSystem.exists(HaqDefines.folders.temp))
        {
            FileSystem.createDirectory(HaqDefines.folders.temp);
        }
        
        var f : FileOutput = php.io.File.append(HaqDefines.folders.temp + "/haquery.log", false);
        if (f != null)
        {
            f.writeString(text != '' ? StringTools.format('%.3f', (Date.now().getTime() - startTime) / 1000.0) + " " + StringTools.replace(text, "\n", "\r\n\t") + "\r\n" : "\r\n");
            f.close();
        }
    }
    
    /**
     * Load bootstrap files from current folder to relativePath.
     */
    private static function loadBootstraps(relativePath:String) : Void
    {
        var folders = StringTools.trim(relativePath, '/').split('/');
        for (i in 1...folders.length + 1)
        {
            var className = folders.slice(0, i).join('.') + '.Bootstrap';
            var clas : Class<HaqBootstrap> = untyped Type.resolveClass(className);
            if (clas != null)
            {
                var b : HaqBootstrap = Type.createInstance(clas, []);
                b.init(config);
            }
        }
    }
    
    /**
     * Disk path to virtual path (url).
     */
    static public function path2url(path:String) : String
    {   
        var realPath = FileSystem.fullPath('').replace("\\", '/') + '/' + path.trim('/\\');
        var rootPath:String = StringTools.replace(Web.getDocumentRoot(), "\\", '/');
        if (!StringTools.startsWith(realPath, rootPath))
        {
            throw "Can't resolve path '" + path + "' with realPath = '" + realPath + "' and rootPath = '" + rootPath + "'.";
        }
        var n = rootPath.length;
        var s = realPath.substr(n);
        return '/' + s.ltrim('/');
    }
    
    static function traceException(e:Dynamic) : Void
    {
        var text = "HAXE EXCEPTION: " + Std.string(e) + "\n"
                 + "Stack trace:" + Stack.toString(Stack.exceptionStack()).replace('\n', '\n\t');
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
    public static inline function print( v : Dynamic ) : Void { return php.Lib.print(v); }

	/**
		Print the specified value on the default output followed by a newline character.
	**/
	public static inline function println( v : Dynamic ) : Void { return php.Lib.println(v); }

	public static inline function dump(v : Dynamic) : Void { return php.Lib.dump(v); }

	/**
		Serialize using native PHP serialization. This will return a Binary string that can be
		stored for long term usage.
	**/
	public static inline function serialize( v : Dynamic ) : String { return php.Lib.serialize(v); }

	/**
		Unserialize a string using native PHP serialization. See [serialize].
	**/
	public static inline function unserialize( s : String ) : Dynamic { return php.Lib.unserialize(s); }

	public static inline function extensionLoaded(name : String) { return php.Lib.extensionLoaded(name); }

	public static inline function isCli() : Bool { return php.Lib.isCli(); }

	public static inline function printFile(file : String) { return php.Lib.printFile(file); }

	public static inline function toPhpArray(a : Array<Dynamic>) : NativeArray { return php.Lib.toPhpArray(a); }

	public static inline function toHaxeArray(a : NativeArray) : Array<Dynamic> { return php.Lib.toHaxeArray(a); }

	public static inline function hashOfAssociativeArray<T>(arr : NativeArray) : Hash<T> { return php.Lib.hashOfAssociativeArray(arr); }
	
	public static inline function associativeArrayOfHash(hash : Hash<Dynamic>) : NativeArray { return php.Lib.associativeArrayOfHash(hash); }

	/**
		For neko compatibility only.
	**/
	public static inline function rethrow( e : Dynamic ) { return php.Lib.rethrow(e); }

	public static inline function getClasses() { return php.Lib.getClasses(); }
	
	/**
	*  Loads types defined in the specified directory.
 	*/
 	public static inline function loadLib(pathToLib : String) : Void { return php.Lib.loadLib(pathToLib); }
}

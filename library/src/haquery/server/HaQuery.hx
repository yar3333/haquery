package haquery.server;

import haxe.Stack;

import php.Lib;
import php.Web;
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

using haquery.StringTools;

class HaQuery
{
    public static var config : HaqConfig = new HaqConfig();
    
    public static var profiler : HaqProfiler = new HaqProfiler();

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
                haxe.Log.trace = HaQuery.trace;
                
                var route = new HaqRoute(Web.getParams().get('route'));
                loadBootstraps(route.path);
                
                if (HaQuery.config.autoSessionStart)
                {
                    Session.start();
                }

                if (config.autoDatabaseConnect && config.db.type!=null)
                {
                    HaqDb.connect(HaQuery.config.db);
                }
                
                if (route.routeType == HaqRouteType.file)
                {
                    untyped __call__('require', route.path);
                }
                else
                {
                    var system = new HaqSystem(route);
                }
        
            profiler.end();
            profiler.traceResults();
        }
        catch (e:Dynamic)
        {
            haquery.server.HaQuery.traceException(e);
        }
    }
	
    static public function redirect(url:String) : Void
    {
        if (HaqSystem.isPostback) HaqInternals.addAjaxResponse("haquery.server.HaQuery.redirect('" + StringTools.addcslashes(url) + "');");
        else                      php.Web.redirect(url);
    }

	static public function reload() : Void
	{
        if (HaqSystem.isPostback) HaqInternals.addAjaxResponse("window.location.reload(true);");
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
        if (HaQuery.config.filterTracesByIP!='')
        {
            if (HaQuery.config.filterTracesByIP!=Web.getClientIP()) return;
        }
        
        var text = '';
        if (Type.getClassName(Type.getClass(v)) == 'String') text += v;
        else
        if (!isNull(v))
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
                Lib.println("<script>if (console) console.debug(decodeURIComponent(\"" + StringTools.urlEncode("SERVER " + text) + "\"));</script>");
            }
        }
        
        if (!FileSystem.exists(HaqCommon.folders.temp))
        {
            FileSystem.createDirectory(HaqCommon.folders.temp);
        }
        
        var f : FileOutput = php.io.File.append(HaqCommon.folders.temp + "/haquery.log", false);
        if (f != null)
        {
            f.writeString(text != '' ? StringTools.format('%.3f', (Date.now().getTime() - startTime) / 1000.0) + " " + StringTools.replace(text, "\n", "\n\t") + "\n" : "\n");
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
    
    static function isNull(e:Dynamic) : Bool
    {
        return untyped __physeq__(e, null);
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
                text += "\n";
        }
        trace(text);
    }
}

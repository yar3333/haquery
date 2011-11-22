package haquery.client;

import haxe.Stack;
import haxe.Firebug;
import haquery.client.HaqInternals;
import haquery.client.HaqSystem;

using haquery.StringTools;

class Lib
{
    static public function run() : Void
    {
        if (Firebug.detect()) Firebug.redirectTraces();
        else                  haxe.Log.trace = haquery.client.Lib.trace;
        var system = new HaqSystem();
    }
	
    static public function redirect(url:String) : Void
    {
        if (url == js.Lib.window.location.href) js.Lib.window.location.reload(true);
        else js.Lib.window.location.href = url;
    }

	static public function reload() : Void
	{
        js.Lib.window.location.reload(true);
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
        // DO NOTHING
    }

	public static inline function confirm( v : Dynamic ) : Bool
	{
		return untyped __js__("confirm")(js.Boot.__string_rec(v,""));
	}
    
    public static var urlVars(urlVars_getter, null) : Hash<String>;
    static var urlVars_cached : Hash<String>;
    static function urlVars_getter() : Hash<String>
    {
        if (urlVars_cached == null)
        {
            urlVars_cached = new Hash<String>();
            var sVars = window.location.href.substr(window.location.href.indexOf('?') + 1).split('&');
            for(sVar in sVars)
            {
                var kv = sVar.split('=');
                urlVars_cached.set(kv[0], kv[1]);
            }
        }
        return urlVars_cached;
    }    
	
    ////////////////////////////////////////////////
    // official methods
    ////////////////////////////////////////////////
    
	public static var isIE(isIE_getter, null) : Bool; private static inline function isIE_getter() : Bool { return js.Lib.isIE; }
	public static var isOpera(isOpera_getter, null) : Bool; private static inline function isOpera_getter() : Bool { return js.Lib.isOpera; }
	public static var document(document_getter, null) : js.Dom.Document; private static inline function document_getter() : js.Dom.Document { return js.Lib.document; }
	public static var window(window_getter, null) : js.Dom.Window; private static inline function window_getter() : js.Dom.Window { return js.Lib.window; }
	
	public static inline function alert( v : Dynamic ) { return js.Lib.alert(v); }
    public static inline function eval( code : String ) : Dynamic { return js.Lib.eval(code); }
	public static inline function setErrorHandler( f ) { return js.Lib.setErrorHandler(f); }
}

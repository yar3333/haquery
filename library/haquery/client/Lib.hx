package haquery.client;

import haxe.Stack;
import haxe.Firebug;
import haquery.client.HaqInternals;
import haquery.client.HaqSystem;

using haquery.StringTools;

class Lib
{
    static public function run(pageFullTag:String)
    {
        if (Firebug.detect())
		{
			//Firebug.redirectTraces();
			haxe.Log.trace = Firebug.trace;
		}
        else
		{
			haxe.Log.trace = haquery.client.Lib.trace;
		}
        
		HaqSystem.run(pageFullTag);
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
package haquery.client;

#if client

import haquery.common.HaqDumper;
import haquery.Exception;
import haquery.client.HaqInternals;
import models.client.Page;
using haquery.StringTools;

@:keep @:expose class Lib
{
	public static var ajax(default, null) : HaqServerCallerAjax;
	public static var websocket(default, null) : HaqServerCallerWebsocket;
	
	public static var page(default, null) : Page;
	
	static public function run(pageFullTag:String)
    {
		haxe.Log.trace = haquery.client.Lib.trace;
        
		ajax = new HaqServerCallerAjax(HaqInternals.pageKey, HaqInternals.pageSecret);
		websocket = HaqInternals.listener != null ? new HaqServerCallerWebsocket(HaqInternals.listener, HaqInternals.pageKey, HaqInternals.pageSecret) : null;
		
		var manager = new HaqTemplateManager();
		page = manager.createPage(pageFullTag);
    }
	
	#if debug
		static public function assert(e:Bool, errorMessage:String=null, ?pos : haxe.PosInfos) : Void
		{
			if (!e) 
			{
				if (errorMessage == null) errorMessage = "";
				throw new Exception("HAQUERY ASSERT " + errorMessage + " in " + pos.fileName + " at line " + pos.lineNumber + ".");
			}
		}
	#else
		static public inline function assert(e:Bool, errorMessage:String=null, ?pos : haxe.PosInfos) : Void
		{
		}
	#end
	
    static function trace(v:Dynamic, ?pos : haxe.PosInfos) : Void
    {
		var s = (pos != null ? pos.fileName + ":" + pos.lineNumber + ": " : "") + (Std.is(v, String) ? cast(v, String) : HaqDumper.getDump(v));
		
		untyped __js__("
			if (typeof console == 'object' && typeof console.log == 'function')
			{
				console.log(s);
			}
		");
    }

	public static inline function confirm( v : Dynamic ) : Bool
	{
		return untyped __js__("confirm")(js.Boot.__string_rec(v,""));
	}
	
    ////////////////////////////////////////////////
    // official methods
    ////////////////////////////////////////////////
    
	public static var document(document_getter, null) : js.Dom.Document; private static inline function document_getter() : js.Dom.Document { return js.Lib.document; }
	public static var window(window_getter, null) : js.Dom.Window; private static inline function window_getter() : js.Dom.Window { return js.Lib.window; }
	
	public static inline function debug() : Void { js.Lib.debug(); }
	public static inline function alert( v : Dynamic ) { js.Lib.alert(v); }
    public static inline function eval( code : String ) : Dynamic { return js.Lib.eval(code); }
	public static inline function setErrorHandler( f ) { js.Lib.setErrorHandler(f); }
}

#end
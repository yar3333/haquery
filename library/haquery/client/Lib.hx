package haquery.client;

import haquery.Exception;
import haxe.Firebug;
import haquery.client.HaqInternals;

@:keep @:expose class Lib
{
	public static var ajax(default, null) : HaqServerCallerAjax;
	public static var websocket(default, null) : HaqServerCallerWebsocket;
	
	static public function run(pageFullTag:String)
    {
		haquery.macros.HaqBuild.preBuild();
		
		haxe.Log.trace = Firebug.detect() 
			? Firebug.trace 
			: haquery.client.Lib.trace;
        
		ajax = new HaqServerCallerAjax(HaqInternals.pageKey, HaqInternals.pageSecret);
		websocket = HaqInternals.listener != "" ? new HaqServerCallerWebsocket(HaqInternals.listener, HaqInternals.pageKey, HaqInternals.pageSecret) : null;
		
		var manager = new HaqTemplateManager();
		var page = manager.createPage(pageFullTag);
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
        // DO NOTHING
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
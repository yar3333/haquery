package haquery.client;

#if client

import haquery.common.HaqDumper;
import haquery.common.Generated;
import stdlib.Exception;
import haquery.client.HaqInternals;
using stdlib.StringTools;

@:keep @:expose class Lib
{
	public static var manager(default, null) : HaqTemplateManager;
	
	static public function run(pageFullTag:String)
    {
		haxe.Log.trace = haquery.client.Lib.trace;
		manager = new HaqTemplateManager();
		manager.createPage(pageFullTag);
    }
	
    static function trace(v:Dynamic, ?pos : haxe.PosInfos) : Void
    {
		#if debug
		
		var s = (pos != null ? pos.fileName + ":" + pos.lineNumber + ": " : "") + (Std.is(v, String) ? cast(v, String) : HaqDumper.getDump(v));
		
		untyped __js__("if (typeof console !== 'undefined') console.log(s)");
		
		#end
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
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
		
		untyped __js__("
			if (typeof console == 'object' && typeof console.log == 'function')
			{
				console.log(s);
			}
			else
			{
				var ie = (function(){

					var undef,
						v = 3,
						div = document.createElement('div'),
						all = div.getElementsByTagName('i');
					
					while (
						div.innerHTML = '<!--[if gt IE ' + (++v) + ']><i></i><![endif]-->',
						all[0]
					);
					
					return v > 4 ? v : undef;
					
				}());
				
				if (ie < 9)
				{
					if (jQuery('#console').length == 0)
					{
						
						jQuery('body').append('<pre id=\"console\" style=\"position:absolute; top:0; left:0; width:500px; height:500px; overflow:scroll; background-color:white; font:12px monospace; z-index:99999; display:none\"></pre>');
						jQuery(document).keydown(function(e)
						{
							if (e.ctrlKey && e.which == 192)
							{
								if (jQuery('#console').is(':visible'))
									jQuery('#console').hide();
								else
									jQuery('#console').show();
							}
						});
					}
					var needScrollDown = jQuery('#console').scrollTop() < jQuery('#console')[0].scrollHeight;
					jQuery('#console').append(StringTools.htmlEscape(s) + '<br/>');
					if (needScrollDown) jQuery('#console').scrollTop(jQuery('#console')[0].scrollHeight);
				}
			}
		");
		
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
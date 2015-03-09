package haquery.client;

import stdlib.Exception;
import stdlib.Debug;
import haquery.common.Generated;
import haquery.client.HaqInternals;
using stdlib.StringTools;

@:keep @:expose class Lib
{
	public static var manager(default, null) : HaqTemplateManager;
	
	public static var page(get_page, set_page) : BasePage;
	
	static function get_page()
	{
		return manager != null ? manager.page : null;
	}
	
	static function set_page(page:BasePage) : BasePage
	{
		if (manager != null) manager.page = page;
		return page;
	}
	
	static public function run(pageFullTag:String)
    {
		haxe.Log.trace = haquery.client.Lib.trace;
		manager = new HaqTemplateManager();
		manager.createPage(pageFullTag);
    }
	
    static function trace(v:Dynamic, ?pos : haxe.PosInfos) : Void
    {
		var s = (pos != null ? pos.fileName + ":" + pos.lineNumber + ": " : "") + (Std.is(v, String) ? cast(v, String) : Debug.getDump(v));
		untyped __js__("if (typeof console !== 'undefined') console.log(s)");
    }
}

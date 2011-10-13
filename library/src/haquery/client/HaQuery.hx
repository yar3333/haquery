package haquery.client;

import haxe.Stack;
import js.Lib;
import haxe.Firebug;
import haquery.client.HaqInternals;
import haquery.client.HaqSystem;

using haquery.StringTools;

class HaQuery
{
    static public function run() : Void
    {
        if (Firebug.detect()) Firebug.redirectTraces();
        else                  haxe.Log.trace = HaQuery.trace;
        var system = new HaqSystem();
    }
	
    static public function redirect(url:String) : Void
    {
        if (url == Lib.window.location.href) Lib.window.location.reload(true);
        else Lib.window.location.href = url;
    }

	static public function reload() : Void
	{
        Lib.window.location.reload(true);
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
}

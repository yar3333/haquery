#if php
package haquery.server;

import php.Lib;
import php.NativeArray;

extern class HaqProfiler
{
    static function __init__() : Void
	{
        Lib.print('HaqProfiler::init');
		untyped __php__("require_once dirname(__FILE__) . '/HaqProfiler.php';");
	}
	
	static public function begin(name:String) : Void;
    static public function end() : Void;
    static public function getResults() : String;
    static public function saveTotalResults() : Void;
    static public function getTotalResults() : NativeArray;
    static public function resetTotalResults() : Void;
}
#end
package haquery.server;

@:native("HaqProfiler") extern class HaqProfiler
{
    static function __init__() : Void
	{
		untyped __php__("require_once 'haquery/server/HaqProfiler.php';");
	}
	
	static public function begin(name:String) : Void;
    static public function end() : Void;
    static public function getResults() : String;
    static public function saveTotalResults() : Void;
    static public function getTotalResults() : php.NativeArray;
    static public function resetTotalResults() : Void;
}

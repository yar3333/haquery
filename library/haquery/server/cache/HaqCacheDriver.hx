package haquery.server.cache;

interface HaqCacheDriver 
{
	public function get(key:String) : Dynamic;
	public function set(key:String, obj:Dynamic) : Void;
	public function remove(key:String) : Void;
	public function removeAll() : Void;
	public function dispose() : Void;
}
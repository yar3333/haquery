package haquery.server.cache;

class HaqCacheDriver_memcached implements HaqCacheDriver
{
	var mc : memcached.Client;
	
	var host : String;
	var port : Int;
	
	public function new(host:String, ?port:Int) : Void
	{
		this.host = host;
		this.port = port;
		
		mc = new memcached.Client(host, port);
	}
	
	public function get(key:String) : Dynamic
	{
		return mc.get(key);
	}
	
	public function set(key:String, obj:Dynamic) : Void
	{
		mc.set(key, obj);
	}
	
	public function remove(key:String) : Void
	{
		mc.delete(key);
	}
	
	public function removeAll() : Void
	{
		mc.flushAll();
	}
	
	public function dispose() : Void
	{
		mc.close();
		mc = null;
	}
}
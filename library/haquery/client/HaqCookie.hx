package haquery.client;

#if client

class HaqCookie
{
	public function new()
	{
	}
	
	public inline function all() : Hash<String>
	{
		return js.Cookie.all();
	}
    
	public inline function exists(name:String) : Bool
	{
		return js.Cookie.exists(name);
	}
   
	public function get(name:String) : String
	{
		return js.Cookie.get(name);
	}
	
	public function set(name:String, value:String, ?expire:Date, ?path:String, ?domain:String)
	{
		js.Cookie.set(name, value, expire != null ? Std.int((expire.getTime() - Date.now().getTime()) / 1000) : null, path, domain);
	}
    
    public inline function remove(name:String, ?path:String, ?domain:String) : Void
	{
		js.Cookie.remove(name, path, domain);
	}
}

#end
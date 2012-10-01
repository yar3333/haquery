package haquery.server;

class HaqCookie
{
	var cookies : Hash<String>;
	var response : HaqResponseCookie;
	
	public function new() : Void
	{
		cookies = Web.getCookies();
		response = new HaqResponseCookie();
	}
	
    public inline function exists(name:String) : Bool
    {
		return cookies.exists(name);
    }
    
    public inline function get(name:String) : String
    {
		return cookies.get(name);
    }
	
	public function set(name:String, value:String, ?expire:Date, ?path:String, ?domain:String) : Void
	{
		cookies.set(name, value);
		response.set(name, value, expire, path, domain);
	}
    
    public function remove(name:String, ?path:String, ?domain:String) : Void
    {
		if (exists(name))
		{
			cookies.remove(name);
			response.remove(name, path, domain);
		}
    }
	
	public inline function send() : Void
	{
		response.send();
	}
}

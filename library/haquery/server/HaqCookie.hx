package haquery.server;

#if server

#if php
import php.Web;
#elseif neko
import neko.Web;
#end

class HaqCookie
{
	var cookies : Hash<String>;
	
	public var response(default, null) : HaqResponseCookie;
	
	public function new() : Void
	{
		this.cookies = Web.getCookies();
		this.response = new HaqResponseCookie();
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
}

#end
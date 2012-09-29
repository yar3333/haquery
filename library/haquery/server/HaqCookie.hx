package haquery.server;

#if php
import php.Web;
#elseif neko
import neko.Web;
#end

class HaqCookie
{
    var isPostback : Bool;
	
	var cookies : Hash<String>;
	
	public function new(isPostback:Bool) : Void
	{
		this.isPostback = isPostback;
		this.cookies = Web.getCookies();
	}
	
	public inline function all() : Hash<String>
    {
		return cookies;
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
		Web.setCookie(name, value, expire, domain, path);
	}
    
    public function remove(name:String, ?path:String, ?domain:String) : Void
    {
		if (exists(name))
		{
			cookies.remove(name);
			set(name, null, new Date(2000,1,1,0,0,0), domain, path);
		}
    }
}

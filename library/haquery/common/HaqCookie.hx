package haquery.common;

#if php
import php.Web;
#elseif neko
import neko.Web;
#end

class HaqCookie
{
    var cookies : Hash<String>;
	
	public function new() : Void
	{
		#if !client
		cookies = Web.getCookies();
		#else
		cookies = js.Cookie.all();
		#end
	}
	
	public function all() : Hash<String>
    {
		return cookies;
    }
    
    public function exists(name:String) : Bool
    {
		return cookies.exists(name);
    }
    
    public function get(name:String) : String
    {
		return cookies.get(name);
    }
	
	public function set(name:String, value:String, ?expire:Date, ?path:String, ?domain:String) : Void
	{
		cookies.set(name, value);
		
		#if !client
		Web.setCookie(name, value, expire, domain, path);
		#else
		js.Cookie.set(name, value, expire != null ? Std.int((expire.getTime() - Date.now().getTime()) / 1000) : null, path, domain);
		#end
	}
    
    public function remove(name:String, ?path:String, ?domain:String) : Void
    {
        cookies.remove(name);
		
		#if !client
		if (exists(name))
		{
			set(name, null, new Date(2000,1,1,0,0,0), domain, path);
		}
        #else
		js.Cookie.remove(name, path, domain);
        #end
    }
}

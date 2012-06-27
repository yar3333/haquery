package haquery;

#if !client
	#if php
	private typedef Web = php.Web;
	#elseif neko
	private typedef Web = neko.Web;
	#end
#end

class Cookie 
{
    static var cookies : Hash<String>;
	
	static inline function init() : Void
	{
		if (cookies == null)
		{
			#if !client
			cookies = Web.getCookies();
			#else
			cookies = js.Cookie.all();
			#end
		}
	}
	
	public static function all() : Hash<String>
    {
		init();
		return cookies;
    }
    
    public static function exists(name:String) : Bool
    {
        init();
		return cookies.exists(name);
    }
    
    public static function get(name:String) : String
    {
        init();
		return cookies.get(name);
    }
	
	public static function set(name:String, value:String, ?expire:Date, ?path:String, ?domain:String) : Void
	{
		init();
		cookies.set(name, value);
		
		#if !client
		Web.setCookie(name, value, expire, domain, path);
		#else
		js.Cookie.set(name, value, expire != null ? Std.int((expire.getTime() - Date.now().getTime()) / 1000) : null, path, domain);
		#end
	}
    
    public static function remove(name:String, ?path:String, ?domain:String) : Void
    {
		init();
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

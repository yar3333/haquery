package haquery;

class Cookie 
{
    public static function all() : Hash<String>
    {
        #if php
            return php.Web.getCookies();
        #else
            return js.Cookie.all();
        #end
    }
    
    public static function exists(name : String) : Bool
    {
        #if php
            return php.Web.getCookies().exists(name);
        #else
            return js.Cookie.exists(name);
        #end
    }
    
    public static function get(name : String)
    {
        #if php
            return php.Web.getCookies().get(name);
        #else
            return js.Cookie.get(name);
        #end
    }
	
	public static function set(name : String, value : String, ?expire : Date, ?path : String, ?domain : String)
	{
		#if php
			return php.Web.setCookie(name, value, expire, domain, path);
		#else
			return js.Cookie.set(name, value, expire != null ? Std.int(expire.getTime() - Date.now().getTime()) : null, path, domain) ;
		#end
	}
    
    public static function remove(name : String, ?path : String, ?domain : String) : Void
    {
        #if php
            return php.Web.setCookie(name, null, new Date(2000,1,1,0,0,0), domain, path);
        #else
            return js.Cookie.remove(name, path, domain);
        #end
    }
}

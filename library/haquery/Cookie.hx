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
    public static function all() : Hash<String>
    {
        #if !client
		return Web.getCookies();
        #else
		return js.Cookie.all();
        #end
    }
    
    public static function exists(name:String) : Bool
    {
        #if !client
		return Web.getCookies().exists(name);
        #else
		return js.Cookie.exists(name);
        #end
    }
    
    public static function get(name:String) : String
    {
        #if !client
		return Web.getCookies().get(name);
        #else
		return js.Cookie.get(name);
        #end
    }
	
	public static function set(name:String, value:String, ?expire:Date, ?path:String, ?domain:String)
	{
		#if !client
		return Web.setCookie(name, value, expire, domain, path);
		#else
		return js.Cookie.set(name, value, expire != null ? Std.int(expire.getTime() - Date.now().getTime()) : null, path, domain) ;
		#end
	}
    
    public static function remove(name:String, ?path:String, ?domain:String) : Void
    {
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

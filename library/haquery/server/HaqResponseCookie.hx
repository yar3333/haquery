package haquery.server;

#if php
import php.Web;
#elseif neko
import neko.Web;
#end

class HaqResponseCookie
{
	var cookies : Hash<{ value:String, expire:Date, path:String, domain:String }>;
	
	public function new()
	{
		reset();
	}
	
	public function set(name:String, value:String, ?expire:Date, ?path:String, ?domain:String) : Void
	{
		cookies.set(name, { value:value, expire:expire, path:path, domain:domain });
	}
    
    public function remove(name:String, ?path:String, ?domain:String) : Void
    {
		cookies.set(name, { value:null, expire:new Date(2000,1,1,0,0,0), path:path, domain:domain  });
    }
	
	public function send() : Void
	{
		for (name in cookies.keys())
		{
			var d = cookies.get(name);
			Web.setCookie(name, d.value, d.expire, d.domain, d.path);
		}
	}
	
	public function reset() : Void
	{
		cookies = new Hash<{ value:String, expire:Date, path:String, domain:String }>();
	}
}

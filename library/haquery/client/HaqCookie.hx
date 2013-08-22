package haquery.client;

#if client

class HaqCookie
{
	var h : Map<String,String>;
	
	public function new() {}
	
	public inline function all() : Map<String,String>
	{
		if (h == null)
		{
			h = new Map<String,String>();
			var a = js.Browser.document.cookie.split(";");
			for (e in a)
			{
				e = StringTools.ltrim(e);
				var t = e.split("=");
				if (t.length < 2) continue;
				try h.set(t[0], StringTools.urlDecode(t[1]))
				catch (e:Dynamic) {}
			}
		}
		return h;
	}
    
	public inline function exists(name:String) : Bool
	{
		return all().exists(name);
	}
   
	public function get(name:String) : String
	{
		return all().get(name);
	}
	
	public function set(name:String, value:String, ?expire:Date, ?path:String, ?domain:String)
	{
		js.Cookie.set(name, value, expire != null ? Std.int((expire.getTime() - Date.now().getTime()) / 1000) : null, path, domain);
		if (h != null)
		{
			h.set(name, value);
		}
	}
    
    public inline function remove(name:String, ?path:String, ?domain:String) : Void
	{
		js.Cookie.remove(name, path, domain);
		if (h != null)
		{
			h.remove(name);
		}
	}
}

#end
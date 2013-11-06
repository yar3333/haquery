package haquery.client;

#if client

class HaqCookie
{
	public function new() {}
	
	public function all() : Map<String,String>
	{
		var h = new Map<String,String>();
		var a = js.Browser.document.cookie.split(";");
		for (e in a)
		{
			e = StringTools.ltrim(e);
			var t = e.split("=");
			if (t.length < 2) continue;
			try h.set(t[0], StringTools.urlDecode(t[1]))
			catch (e:Dynamic) {}
		}
		return h;
	}
    
	public function exists(name:String) : Bool
	{
		for (e in js.Browser.document.cookie.split(";"))
		{
			e = StringTools.ltrim(e);
			var t = e.split("=");
			if (t[0] == name) return true;
		}
		return false;
	}
   
	public function get(name:String) : String
	{
		for (e in js.Browser.document.cookie.split(";"))
		{
			e = StringTools.ltrim(e);
			var t = e.split("=");
			if (t[0] == name)
			{
				return t.length > 1 ? (try StringTools.urlDecode(t[1]) catch(_:Dynamic) t[1]) : null;
			}
		}
		return null;
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
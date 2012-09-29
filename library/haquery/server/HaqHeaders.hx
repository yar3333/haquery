package haquery.server;

#if php
import php.Web;
#elseif neko
import neko.Web;
#end

class HaqHeaders
{
    var isPostback : Bool;
	
	var requestHeaders : List<{ value:String, header:String }>;
	var responseHeaders : List<{ value:String, header:String }>;
	
	public function new(isPostback:Bool) : Void
	{
		this.isPostback = isPostback;
		this.requestHeaders = Web.getClientHeaders();
		this.responseHeaders = new List<{ value:String, header:String }>();
	}
	
    public function get(name:String) : String
    {
		for (h in requestHeaders)
		{
			if (h.header == name) return h.value;
		}
		return null;
    }
	
	public function set(name:String, value:String) : Void
	{
		for (h in responseHeaders)
		{
			if (h.header == name)
			{
				h.value = value;
				return;
			}
		}
		responseHeaders.push({ header:name, value:value });
	}
}

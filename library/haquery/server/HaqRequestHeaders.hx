package haquery.server;

#if server

#if php
import php.Web;
#elseif neko
import neko.Web;
#end

class HaqRequestHeaders
{
	var headers : List<{ value:String, header:String }>;
	
	public function new() : Void
	{
		headers = Web.getClientHeaders();
	}
	
    public function get(name:String) : String
    {
		name = name.toLowerCase();
		for (h in headers)
		{
			if (h.header.toLowerCase() == name) return h.value;
		}
		return null;
    }
}

#end
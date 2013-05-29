package haquery.server;

#if server

#if php
import php.Web;
#elseif neko
import neko.Web;
#end

class HaqRequestHeaders
{
    public function new() {}
	
	public function get(name:String) : String
    {
		return Web.getClientHeader(name);
    }
}

#end
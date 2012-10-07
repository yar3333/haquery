package haquery.server;

#if php
import php.Web;
#elseif neko
import neko.Web;
#end

using haquery.StringTools;

class Uuid 
{
	static var n = 0;
	
	public static function newUuid() : String
	{
		var time = Math.floor(Date.now().getTime());
        var uuid = getHexClientIP().substr(0, 8).rpad("0", 8) 
				 + "-" + StringTools.hex(Math.floor(time / 0x10000), 8)
				 + "-" + StringTools.hex(time % 0x10000, 8)
				 + "-" + StringTools.hex(Std.random(0x10000), 4)
				 + "-" + StringTools.hex(n, 4);
		n = (n + 1) % 0x10000;
		return uuid;
	}
	
	static function getHexClientIP()
    {
		var ip = Web.getClientHeader("X-Real-IP");
		if (ip == null || ip == "")
		{
			ip = Web.getClientIP();
		}
		
        var hex = "";
        for (part in ip.split('.'))
        {
            hex += StringTools.hex(Std.parseInt(part), 2);
        }
        return hex;
    }
}

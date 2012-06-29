package haquery.server;

import haquery.server.Web;
using haquery.StringTools;

class Uuid 
{
	public static function newUuid() : String
	{
		var time = Math.floor(Date.now().getTime());
        return getHexClientIP().substr(0, 8).rpad("0", 8) 
			 + "-" + StringTools.hex(Math.floor(time / 65536), 8)
			 + "-" + StringTools.hex(time % 65536, 8)
			 + "-" + StringTools.hex(Math.floor(Math.random() * 65536), 4)
			 + "-" + StringTools.hex(Math.floor(Math.random() * 65536), 4);
	}
	
	static function getHexClientIP()
    {
        var ip = Web.getClientIP();
        var hex = "";
        for (part in ip.split('.'))
        {
            hex += StringTools.hex(Std.parseInt(part), 2);
        }
        return hex;
    }
}
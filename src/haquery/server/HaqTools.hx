package haquery.server;

import php.Web;
import Type;

class HaqTools 
{
	static function serverVarToClientString(v:Dynamic) : String
	{
		if (untyped __physeq__(v, null)) return 'null';
		if (untyped __physeq__(v, true)) return 'true';
		if (untyped __physeq__(v, false)) return 'false';
		if (Type.typeof(v) == ValueType.TInt) return Std.string(v);
		
		if (Type.typeof(v) == ValueType.TObject)
		{
			if (Type.getClassName(Type.getClass(v)) == 'String')
			{
				return 'StringTools.unescape("' + StringTools.escape(v) + '")';
			}
			if (Type.getClassName(Type.getClass(v)) == 'Date')
			{
				var date : Date = cast(v, Date);
				return "new Date(" + date.getTime() + ")";
			}
		}
		
		throw "Can't convert this type from server to client (typeof = " + Type.typeof(v) + ").";
	}
	
	public static function getCallClientFunctionString(func:String, params:Array<Dynamic>) : String
	{
		return func 
			+ "(" 
                + (params!=null ? Lambda.map(params, serverVarToClientString).join(', ') : '')
			+ ")";
	}
    
    static function hexClientIP()
    {
        var ip : String = Web.getClientIP();
        var parts = ip.split('.');
        var hex = "";
        for (part in parts)
        {
            hex += StringTools.format("%02x", part);
        }
        return hex;
    }
    
    public static function uuid() : String
    {
        var time : Int = Math.floor(Date.now().getTime());
        return StringTools.format("%08s", hexClientIP().substr(0,8))
              +StringTools.format("-%08x", time / 65536)
              +StringTools.format("-%04x", time % 65536)
              +StringTools.format("-%04x", Math.floor(Math.random() * 65536))
              +StringTools.format("%04x", Math.floor(Math.random() * 65536));
    }
}
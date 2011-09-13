package haquery.server;

import Type;
import php.Web;
import haquery.StringTools;

class HaqTools 
{
	static function serverVarToClientString(v:Dynamic) : String
	{
		switch (Type.typeof(v))
        {
            case ValueType.TNull:
                return 'null';
            
            case ValueType.TBool:
                return  cast(v, Bool) ? 'true' : 'false';
            
            case ValueType.TInt, ValueType.TFloat:
                return Std.string(v);
            
            case ValueType.TObject:
                return 'haquery.StringTools.unescape("' + StringTools.escape(v) + '")';
            
            case ValueType.TClass(clas):
                if (Type.getClassName(clas) == 'String')
                {
                    return 'haquery.StringTools.unescape("' + StringTools.escape(v) + '")';
                }
                if (Type.getClassName(clas) == 'Date')
                {
                    var date : Date = cast(v, Date);
                    return "new Date(" + date.getTime() + ")";
                }
            default:
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
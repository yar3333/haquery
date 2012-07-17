package haquery;

import Type.ValueType;

class Std 
{
	public static inline function is( v : Dynamic, t : Dynamic ) : Bool return std.Std.is(v, t)
	
	public static inline function string( s : Dynamic ) : String { return std.Std.string(s);  }
	
	public static inline function int( x : Float ) : Int { return std.Std.int(x);  }
	
	public static function parseInt( x : String, ?defaultValue:Int ) : Null<Int>
	{
		return x != null
			? (~/^\s*[+-]?\s*(?:0x)?\d{1,9}\s*$/.match(x) ? std.Std.parseInt(x) : defaultValue)
			: defaultValue;
	}
	
	public static function parseFloat( x : String, ?defaultValue:Float ) : Null<Float>
	{
		return x != null
			? (~/^\s*[+-]?\s*\d{1,9}(?:[.]\d{1,9})?(?:e[+-]?\d{1,9})?\s*$/.match(x) ? std.Std.parseFloat(x) : defaultValue)
			: defaultValue;
	}
	
	public static inline function random( x : Int ) : Int { return std.Std.random(x);  }
	
    public static function bool(v:Dynamic) : Bool
    {
		if ( v == false || v == null || v == 0 || v == "" || v == "0")
		{
			return false;
		}
		
		switch (Type.typeof(v))
		{
			case ValueType.TClass(c):
				if (c == String)
				{
					if (v.toLowerCase() == "false" || v.toLowerCase() == "off")
					{
						return false;
					}
				}
			default:
		}
		
		return true;
    }
	
	public static function parseValue( x:String ) : Dynamic
	{
		var value : Dynamic = x;
		var valueLC = value != null ? value.toLowerCase() : null;
		var parsedValue : Dynamic;
		
		if (valueLC == "true") value = true;
		else
		if (valueLC == "false") value = false;
		else
		if (valueLC == "null") value = null;
		else
		if ((parsedValue = Std.parseInt(value)) != null) value = parsedValue;
		else
		if ((parsedValue = Std.parseFloat(value)) != null) value = parsedValue;
		
		return value;
	}
}

package haquery;

class Std 
{
	public static inline function is( v : Dynamic, t : Dynamic ) : Bool { return HaxeStd.is(v, t);  }
	public static inline function string( s : Dynamic ) : String { return HaxeStd.string(s);  }
	public static inline function int( x : Float ) : Int { return HaxeStd.int(x);  }
	public static inline function parseInt( x : String ) : Null<Int> { return HaxeStd.parseInt(x);  }
	public static inline function parseFloat( x : String ) : Float { return HaxeStd.parseFloat(x);  }
	public static inline function random( x : Int ) : Int { return HaxeStd.random(x);  }
	
    public static function bool(v:Dynamic) : Bool
    {
		return v != false && v != null && v != 0 && v != "" && v != "0" && v != "false" && v != "off";
    }
}

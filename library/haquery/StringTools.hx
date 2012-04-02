package haquery;

class StringTools 
{
	public static inline function urlEncode( s : String ) : String untyped { return HaxeStringTools.urlEncode(s); }
	
	public static inline function urlDecode( s : String ) : String untyped { return HaxeStringTools.urlDecode(s); }

	public static inline function htmlEscape( s : String ) : String { return HaxeStringTools.htmlEscape(s); }

	public static inline function htmlUnescape( s : String ) : String { return HaxeStringTools.htmlUnescape(s); }

	public static inline function startsWith( s : String, start : String ) { return HaxeStringTools.startsWith(s, start); }

	public static inline function endsWith( s : String, end : String ) { return HaxeStringTools.endsWith(s, end); }

	public static inline function isSpace( s : String, pos : Int ) : Bool { return HaxeStringTools.isSpace(s, pos); }

	public static function ltrim( s : String, chars : String = null ) : String
    {
        #if php
		return chars == null ? untyped __call__("ltrim", s) : untyped __call__("ltrim", s, chars);
        #else
        if (chars == null)
		{
			return HaxeStringTools.ltrim(s);
		}
		while (chars.indexOf(s.substr(0, 1)) >= 0)
		{
			s = s.substr(1, s.length - 1);
		}
		return s;
        #end
    }

	public static function rtrim( s : String, chars : String = null ) : String
    {
        #if php
		return chars == null ? untyped __call__("rtrim", s) : untyped __call__("rtrim", s, chars);
        #else
        if (chars == null)
		{
			return HaxeStringTools.rtrim(s);
		}
		while (chars.indexOf(s.substr(s.length - 1, 1)) >= 0)
		{
			s = s.substr(0, s.length - 1);
		}
		return s;
        #end
    }

	public static function trim( s : String, chars : String = null ) : String
    { 
        #if php
		return chars == null ? untyped __call__("trim", s) : untyped __call__("trim", s, chars);
        #else
        if (chars == null)
		{
			return HaxeStringTools.trim(s);
		}
		return rtrim(ltrim(s, chars), chars);
        #end
    }

	public static inline function rpad( s : String, c : String, l : Int ) : String { return HaxeStringTools.rpad(s, c, l); }

	public static inline function lpad( s : String, c : String, l : Int ) : String { return HaxeStringTools.lpad(s, c, l); }

	public static inline function replace( s : String, sub : String, by : String ) : String { return HaxeStringTools.replace(s, sub, by); }

	public static inline function hex( n : Int, ?digits : Int ) { return HaxeStringTools.hex(n, digits); }

	public static inline function fastCodeAt( s : String, index : Int ) : Int { return HaxeStringTools.fastCodeAt(s, index); }

	public static inline function isEOF( c : Int ) : Bool { return HaxeStringTools.isEOF(c); }
    
	#if (php || js)
	public static inline function jsonDecode(s : String) : Dynamic
	{
		#if php
			return untyped __call__('json_decode', s);
		#elseif js
			return js.Lib.eval("(" + s + ")");
	    #end
	}
	#end

    #if php
    public static inline function toUpperCaseNational(s : String) : String
    {
        return untyped __call__('mb_strtoupper', s, 'UTF-8');
    }
    
    public static inline function toLowerCaseNational(s : String) : String
    {
        return untyped __call__('mb_strtolower', s, 'UTF-8');
    }
    
	public static inline function stripTags(s : String) : String
	{
		return untyped __call__('strip_tags', s);
	}
	
	public static inline function format(template : String, value : Dynamic) : String
	{
		return untyped __call__('sprintf', template, value);
	}

	public static inline function jsonEncode(x : Dynamic) : String
	{
		return untyped __call__('json_encode', x);
	}
    
	public static inline function hexdec(s : String) : Int
	{
		return untyped __call__('hexdec', s);
	}
    
    public static inline function lengthNational(s:String) : Int
    {
        return untyped __call__('mb_strlen', s, 'UTF-8');
    }
    
    public static function substrNational(s:String, pos:Int, ?len:Int) : String
    {
        return len != null 
            ? untyped __call__('mb_substr', s, pos, len, 'UTF-8') 
            : untyped __call__('mb_substr', s, pos, lengthNational(s) - pos, 'UTF-8');
    }
	#end
    
	public static function addcslashes(s:String) : String
    {
		#if php
        return untyped __call__('addcslashes', s, "\'\"\t\r\n\\");
		#else
		return new EReg("\'\"\t\r\n\\", "g").replace(s, "\\\\0");
		#end
    }
}
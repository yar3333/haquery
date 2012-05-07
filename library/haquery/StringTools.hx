package haquery;

class StringTools 
{
	public static inline function urlEncode( s : String ) : String untyped { return std.StringTools.urlEncode(s); }
	
	public static inline function urlDecode( s : String ) : String untyped { return std.StringTools.urlDecode(s); }

	public static inline function htmlEscape( s : String ) : String { return std.StringTools.htmlEscape(s); }

	public static inline function htmlUnescape( s : String ) : String { return std.StringTools.htmlUnescape(s); }

	public static inline function startsWith( s : String, start : String ) { return std.StringTools.startsWith(s, start); }

	public static inline function endsWith( s : String, end : String ) { return std.StringTools.endsWith(s, end); }

	public static inline function isSpace( s : String, pos : Int ) : Bool { return std.StringTools.isSpace(s, pos); }

	public static function ltrim( s : String, chars : String = null ) : String
    {
        #if php
		return chars == null ? untyped __call__("ltrim", s) : untyped __call__("ltrim", s, chars);
        #else
        if (chars == null)
		{
			return std.StringTools.ltrim(s);
		}
		while (s.length > 0 && chars.indexOf(s.substr(0, 1)) >= 0)
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
			return std.StringTools.rtrim(s);
		}
		while (s.length > 0 && chars.indexOf(s.substr(s.length - 1, 1)) >= 0)
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
			return std.StringTools.trim(s);
		}
		return rtrim(ltrim(s, chars), chars);
        #end
    }

	public static inline function rpad( s : String, c : String, l : Int ) : String { return std.StringTools.rpad(s, c, l); }

	public static inline function lpad( s : String, c : String, l : Int ) : String { return std.StringTools.lpad(s, c, l); }

	public static inline function replace( s : String, sub : String, by : String ) : String { return std.StringTools.replace(s, sub, by); }

	public static inline function hex( n : Int, ?digits : Int ) { return std.StringTools.hex(n, digits); }

	public static inline function fastCodeAt( s : String, index : Int ) : Int { return std.StringTools.fastCodeAt(s, index); }

	public static inline function isEOF( c : Int ) : Bool { return std.StringTools.isEOF(c); }
    
	public static inline function jsonEncode(x : Dynamic) : String
	{
		#if php
		return untyped __call__('json_encode', x);
		#else
		return hxjson2.JSON.encode(x);
		#end
	}
	
	public static inline function jsonDecode(s : String) : Dynamic
	{
		#if php
		return untyped __call__('json_decode', s);
		#elseif js
		return js.Lib.eval("(" + s + ")");
		#else
		return hxjson2.JSON.decode(s);
	    #end
	}

    public static inline function toUpperCaseNational(s : String) : String
    {
		#if php
		return untyped __call__('mb_strtoupper', s, 'UTF-8');
		#else
		//var lower = "абвгдеёжзийклмнопрстуфхцчшщьыъэюя";
		//var upper = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЫЪЭЮЯ";
		// TODO: toUpperCaseNational
		return s.toUpperCase();
		#end
    }
    
    public static inline function toLowerCaseNational(s : String) : String
    {
        #if php
		return untyped __call__('mb_strtolower', s, 'UTF-8');
		#else
		//var lower = "абвгдеёжзийклмнопрстуфхцчшщьыъэюя";
		//var upper = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЫЪЭЮЯ";
		// TODO: toLowerCaseNational
		return s.toLowerCase();
		#end
    }
    
	public static inline function hexdec(s : String) : Int
	{
		#if php
		return untyped __call__('hexdec', s);
		#else
		return Std.parseInt("0x" + s);
		#end
	}
    
    public static inline function lengthNational(s:String) : Int
    {
        #if php
		return untyped __call__('mb_strlen', s, 'UTF-8');
		#else
		return haxe.Utf8.length(s);
		#end
    }
    
    public static function substrNational(s:String, pos:Int, ?len:Int) : String
    {
        #if php
        return len != null 
            ? untyped __call__('mb_substr', s, pos, len, 'UTF-8')
            : untyped __call__('mb_substr', s, pos, lengthNational(s) - pos, 'UTF-8');
		#else
        return len != null 
            ? haxe.Utf8.sub(s, pos, len)
            : haxe.Utf8.sub(s, pos, lengthNational(s) - pos);
		#end
    }
	
	public static function addcslashes(s:String) : String
    {
		#if php
        return untyped __call__('addcslashes', s, "\'\"\t\r\n\\");
		#else
		return new EReg("\'\"\t\r\n\\\\", "g").replace(s, "\\\\0");
		#end
    }
	
	#if php
	public static inline function stripTags(s : String) : String
	{
		return untyped __call__('strip_tags', s);
	}
	
	public static inline function format(template : String, value : Dynamic) : String
	{
		return untyped __call__('sprintf', template, value);
	}
	#end
}
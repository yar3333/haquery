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

	public static inline function ltrim( s : String #if php , chars : String = null #end ) : String
    {
        #if php
		return untyped __call__("ltrim", s, chars);
        #else
        return HaxeStringTools.ltrim(s);
        #end
    }

	public static inline function rtrim( s : String #if php , chars : String = null #end ) : String
    {
        #if php
		return untyped __call__("rtrim", s, chars);
        #else
        return HaxeStringTools.rtrim(s);
        #end
    }

	public static inline function trim( s : String #if php , chars : String = null #end ) : String
    { 
        #if php
		return untyped __call__("rtrim", s, chars);
        #else
        return HaxeStringTools.trim(s);
        #end
    }

	public static inline function rpad( s : String, c : String, l : Int ) : String { return HaxeStringTools.rpad(s, c, l); }

	public static inline function lpad( s : String, c : String, l : Int ) : String { return HaxeStringTools.lpad(s, c, l); }

	public static inline function replace( s : String, sub : String, by : String ) : String { return HaxeStringTools.replace(s, sub, by); }

	public static inline function hex( n : Int, ?digits : Int ) { return HaxeStringTools.hex(n, digits); }

	public static inline function fastCodeAt( s : String, index : Int ) : Int { return HaxeStringTools.fastCodeAt(s, index); }

	public static inline function isEOF( c : Int ) : Bool { return HaxeStringTools.isEOF(c); }
    
    public static function unescape(s:String) : String
    {
        #if php
		untyped __php__("
			$text = explode('%u', $s);
			$r = '';
			for ($i = 0; $i < count($text); $i++)
			{
				$r .= pack('H*', $text[$i]);
			}
			$r = mb_convert_encoding($r, 'UTF-8', 'UTF-16');
		");
		return untyped __var__('r');
        #else
        return untyped __js__('unescape(s)');
        #end
    }

    public static function escape(s:String) : String
    {
        #if php
		untyped __php__("
			$text = mb_convert_encoding($s, 'UTF-16', 'UTF-8');
			$r = '';
			for ($i = 0; $i < mb_strlen($text, 'UTF-16'); $i++)
			{
				$r .= '%u'.bin2hex(mb_substr($text, $i, 1, 'UTF-16'));
			}
		");
		return untyped __var__('r');
        #else
        return untyped __js__('escape(s)');
        #end
    }

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
	
	public static inline function jsonDecode(s : String) : Dynamic
	{
		return untyped __call__('json_decode', s);
	}
    
	public static inline function hexdec(s : String) : Int
	{
		return untyped __call__('hexdec', s);
	}
    #end

}
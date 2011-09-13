package php;

class StringTools
{
    public static function unescape(s:String) : String
    {
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
    }

    public static function escape(text:String) : String
    {
		untyped __php__("
			$text = mb_convert_encoding($text, 'UTF-16', 'UTF-8');
			$r = '';
			for ($i = 0; $i < mb_strlen($text, 'UTF-16'); $i++)
			{
				$r .= '%u'.bin2hex(mb_substr($text, $i, 1, 'UTF-16'));
			}
		");
		return untyped __var__('r');
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
}
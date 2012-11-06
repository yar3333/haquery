package haquery.tools;

import neko.Lib;

class HaqNative
{
	public static function copyFilePreservingAttributes(src:String, dst:String) : Void
	{
		var r : Int = Lib.nekoToHaxe(copy_file_preserving_attributes(Lib.haxeToNeko(src), Lib.haxeToNeko(dst)));
		
		if (r != 0)
		{
			if (r == 1)
			{
				throw "Error open source file ('" + src + "').";
			}
			else
			if (r == 2)
			{
				throw "Error open dest file ('" + dst + "').";
			}
			else
			if (r == 3)
			{
				throw "Error get attributes from source file ('" + src + "').";
			}
			else
			if (r == 4)
			{
				throw "Error set attributes to dest file ('" + dst + "').";
			}
			else
			{
				throw "Error code " + r + ".";
			}
		}
	}

	private static var copy_file_preserving_attributes = Lib.loadLazy("haqnative","copy_file_preserving_attributes", 2);
}

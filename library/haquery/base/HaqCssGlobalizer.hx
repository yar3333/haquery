package haquery.base;

import haquery.common.HaqDefines;
using stdlib.StringTools;

class HaqCssGlobalizer 
{
	public var prefix : String;

	public function new(fullTag:String) 
	{
		this.prefix = fullTag.replace(".", "_") + HaqDefines.DELIMITER;
	}
	
	public function className(name:String) : String
	{
		#if client
		if (!Std.is(name, String)) return name;
		#end
		return ~/[~]|\bL-/g.replace(name, prefix);
	}

	public function selector(selector:String) : String
	{
		#if client
        if (!Std.is(selector, String)) return selector;
		#end
		return ~/[.][~]|[.]L-/g.replace(selector, "." + prefix);
	}
}
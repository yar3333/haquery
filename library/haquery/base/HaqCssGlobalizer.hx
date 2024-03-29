package haquery.base;

import haquery.common.HaqDefines;
using stdlib.StringTools;

class HaqCssGlobalizer 
{
	static var reClassName = ~/[~]|\bL-/g;
	static var reSelector = ~/[.][~]|[.]L-/g;
	
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
		return reClassName.replace(name, prefix);
	}

	public function selector(selector:String) : String
	{
		#if client
        if (!Std.is(selector, String)) return selector;
		#end
		return reSelector.replace(selector, "." + prefix);
	}
}
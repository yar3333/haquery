package haquery.base;

import haquery.common.HaqDefines;
using haquery.StringTools;

class HaqCssGlobalizer 
{
	public var prefix : String;

	public function new(fullTag:String) 
	{
		this.prefix = fullTag.replace(".", "_") + HaqDefines.DELIMITER;
	}
	
	public function className(name:String) : String
	{
        if (name == null)
		{
			return "";
		}
		return ~/[~]/g.replace(name, prefix);
	}

	public function selector(selector:String) : String
	{
        if (selector == null)
		{
			return "";
		}
		return ~/[.][~]/g.replace(selector, "." + prefix);
	}
}
package haquery.server;

class HaqTemplateTools 
{
	public static function getPack(fullTag:String)
	{
		var n = fullTag.lastIndexOf(".");
		return n >= 0 ? fullTag.substr(0, n) : "";
	}
	
	public static function getTag(fullTag:String)
	{
		var n = fullTag.lastIndexOf(".");
		return n >= 0 ? fullTag.substr(n + 1) : fullTag;
	}
}
package haquery.server;

class HaqCli 
{
	public static function getURI() : String
	{
		var args = Sys.args();
		return args.length > 0 ? args[0] : "";
	}
	
	public static function getParams() : Hash<String>
	{
		var params = new Hash<String>();
		var args = Sys.args();
		for (i in 1...args.length)
		{
			var kv = args[i].split("=");
			var k = StringTools.urlDecode(StringTools.trim(kv[0]));
			if (k != "")
			{
				params.set(k, kv.length > 1 ? StringTools.urlDecode(StringTools.trim(kv[1])) : "");
			}
		}
		return params;
	}
	
}
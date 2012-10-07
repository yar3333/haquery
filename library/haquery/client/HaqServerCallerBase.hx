package haquery.client;

import haxe.Unserializer;
using haquery.StringTools;

class HaqServerCallerBase 
{
	function processServerAnswer(data:String, ?callb:Dynamic->Void) : Void
	{
		var okMsg = "HAQUERY_OK";
		if (data.startsWith(okMsg))
		{
			var resultAndCode = data.substr(okMsg.length);
			var n = resultAndCode.indexOf("\n");
			if (n >= 0)
			{
				var result = Unserializer.run(resultAndCode.substr(0, n));
				var code = resultAndCode.substr(n + 1);
				Lib.eval(code);
				if (callb != null)
				{
					callb(result);
				}
			}
		}
		else
		{
			if (data != '')
			{
				var errWin = Lib.window.open("", "HAQUERY_ERROR_SERVER_CALL");
				errWin.document.write(data);
			}
		}
	}
}
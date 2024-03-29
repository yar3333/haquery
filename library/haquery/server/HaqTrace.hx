package haquery.server;

import haquery.common.HaqDefines;
import haxe.PosInfos;
import stdlib.Debug;
import stdlib.FileSystem;
import sys.io.File;
using stdlib.StringTools;

class HaqTrace 
{
	public static var logFilePathPrefix = "";
	
	public static function log(v:Dynamic, ?clientIP:String, ?filterTracesByIP:String, ?page:HaqPage, ?pos:PosInfos)
	{
		if (clientIP == null || filterTracesByIP == null || filterTracesByIP == "" || filterTracesByIP == clientIP)
		{
			var text = object2string(v, pos);
			
			if (page != null && text != '' && (page.contentType.startsWith("text/html;") || page.contentType == "text/html"))
			{
				if (text.startsWith("EXCEPTION") || text.startsWith("ERROR"))
				{
					writeToConsole(page, "error", text);
				}
				else if (text.startsWith("WARNING"))
				{
					writeToConsole(page, "warn", text);
				}
				else
				{
					writeToConsole(page, "info", text);
				}
			}
			
			writeToFile(text);
		}
	}
	
	static function object2string(v:Dynamic, pos:PosInfos) : String
	{
        if (Std.isOfType(v, String))
		{
			var s : String = cast v;
			if (!s.startsWith('EXCEPTION:') && !s.startsWith('HAQUERY'))
			{
				s = pos.fileName + ":" + pos.lineNumber + " : " + s;
			}
			return s;
		}
        else
        if (v != null)
        {
            return "DUMP\n" + Debug.getDump(v);
        }
		return "";
	}
	
	/**
	 * type: log, debug, info, warn, error
	 */
	static function writeToConsole(page:HaqPage, type:String, text:String)
	{
		#if debug
		if (page != null)
		{
			page.addAjaxResponse("if (typeof console !== 'undefined') console." + type + "(decodeURIComponent('" + StringTools.urlEncode(text) + "'));");
		}
		#end
	}
	
	static function writeToFile(text:String)
	{
		var tempFolder = logFilePathPrefix + HaqDefines.folders.temp;
		
		if (!FileSystem.exists(tempFolder))
        {
            FileSystem.createDirectory(tempFolder);
        }
        
        var f = File.append(tempFolder + "/haquery.log");
        if (f != null)
        {
			if (text != "")
			{
				var prefix = DateTools.format(Date.now(), "%Y-%m-%d %H:%M:%S ");
				text = prefix + StringTools.replace(text, "\n", "\r\n\t") + "\r\n";
			}
			else
			{
				text = "\r\n";
			}
			f.writeString(text);
            f.close();
        }
	}
}

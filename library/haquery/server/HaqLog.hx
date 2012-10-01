package haquery.server;

import haxe.FirePHP;
import haxe.PosInfos;
import haquery.common.HaqDefines;
import haquery.common.HaqDumper;
import sys.io.FileOutput;
import sys.io.File;
using haquery.StringTools;

class HaqLog 
{
	public static function globalTrace(startTime:Float, v:Dynamic, pos:PosInfos)
    {
		writeToFile(startTime, object2string(v, pos));
    }
	
	public static function pageTrace(startTime:Float, page:HaqPage, v:Dynamic, pos:PosInfos)
	{
		if (Lib.config.filterTracesByIP == null || Lib.config.filterTracesByIP == '' || Lib.config.filterTracesByIP == page.clientIP)
		{
			var text = object2string(v, pos);
			
			if (text != '' && !Lib.isCli())
			{
					try
					{
						var firePHP = FirePHP.getInstance(true);
						if (text.startsWith('EXCEPTION:'))
						{
							firePHP.error(text);
						}
						else if (text.startsWith('HAQUERY'))
						{
							firePHP.info(text);
						}
						else
						{
							firePHP.warn(text);
						}
					}
					catch (e:Dynamic)
					{
						text += "\n\nFirePHP exception: " + e;
					}
					// TODO: trace fix
					/*if (!isPostback)
					{
						NativeLib.println("<script>if (console) console.debug(decodeURIComponent(\"" + StringTools.urlEncode("SERVER " + text) + "\"));</script>");
					}*/
			}
			
			writeToFile(startTime, text);
		}
	}
	
	static function object2string(v:Dynamic, pos:PosInfos) : String
	{
        if (Std.is(v, String))
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
            return "DUMP\n" + HaqDumper.getDump(v);
        }
		return "";
	}
	
	static function writeToFile(startTime:Float, text:String)
	{
		if (!FileSystem.exists(HaqDefines.folders.temp))
        {
            FileSystem.createDirectory(HaqDefines.folders.temp);
        }
        
        var f : FileOutput = File.append(HaqDefines.folders.temp + "/haquery.log");
        if (f != null)
        {
			if (text != "")
			{
				var dt = Sys.time() - startTime;
				var duration = Math.floor(dt) + "." + Std.string(Math.floor((dt - Math.floor(dt)) * 1000)).lpad("0", 3);
				text = Date.fromTime(startTime * 1000) + " " + duration + " " +  StringTools.replace(text, "\n", "\r\n\t") + "\r\n";
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
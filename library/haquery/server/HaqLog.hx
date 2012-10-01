package haquery.server;

import haxe.FirePHP;
import haquery.common.HaqDumper;

class HaqLog 
{
	public static function trace(v:Dynamic, ?pos:haxe.PosInfos) : Void
    {
        var text = '';
        if (Type.getClass(v) == String)
		{
			text += v;
		}
        else
        if (v != null)
        {
            text += "DUMP\n" + HaqDumper.getDump(v);
        }

		if (text != '' && !Lib.isCli())
        {
			if (!isHeadersSent)
            {
                try
                {
                    if (text.startsWith('EXCEPTION:'))
                    {
                        FirePHP.getInstance(true).error(text);
                    }
                    else if (text.startsWith('HAQUERY'))
                    {
                        FirePHP.getInstance(true).info(text);
                    }
                    else
                    {
                        text = pos.fileName + ":" + pos.lineNumber + " : " + text;
                        FirePHP.getInstance(true).warn(text);
                    }
                }
                catch (s:Dynamic)
                {
                    text += "\n\nFirePHP exception: " + s;
                }
            }
            else
            {
                // TODO: trace fix
				/*if (!isPostback)
				{
					NativeLib.println("<script>if (console) console.debug(decodeURIComponent(\"" + StringTools.urlEncode("SERVER " + text) + "\"));</script>");
				}*/
            }
        }
		
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
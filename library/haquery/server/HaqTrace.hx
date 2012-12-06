package haquery.server;

#if server

#if php
private typedef NativeLib = php.Lib;
#elseif neko
private typedef NativeLib = neko.Lib;
#end

import haxe.PosInfos;
import haquery.common.HaqDefines;
import haquery.common.HaqDumper;
import sys.io.File;
using haquery.StringTools;

class HaqTrace 
{
	public static function global(v:Dynamic, pos:PosInfos)
    {
		var text = object2string(v, pos);
		
		#if neko
		if (HaqSystem.listener != null)
		{
			NativeLib.println(text);
		}
		#else
		NativeLib.println(text);
		#end
		
		writeToFile(text);
    }
	
	public static function page(page:HaqPage, clientIP:String, v:Dynamic, pos:PosInfos)
	{
		if (Lib.config.filterTracesByIP == null || Lib.config.filterTracesByIP == '' || Lib.config.filterTracesByIP == clientIP)
		{
			var text = object2string(v, pos);
			
			if (text != '')
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
	
	/**
	 * type: log, debug, info, warn, error
	 */
	static function writeToConsole(page:HaqPage, type:String, text:String)
	{
		if (page != null)
		{
			page.addAjaxResponse("if (console) console." + type + "(decodeURIComponent('" + StringTools.urlEncode(text) + "'));");
		}
	}
	
	static function writeToFile(text:String)
	{
		if (!FileSystem.exists(HaqDefines.folders.temp))
        {
            FileSystem.createDirectory(HaqDefines.folders.temp);
        }
        
        var f = File.append(HaqDefines.folders.temp + "/haquery.log");
        if (f != null)
        {
			if (text != "")
			{
				text = "[" + #if neko 
								(HaqSystem.listener == null ? " " : HaqSystem.listener.name)
							 #else 
								" "
							 #end + "] " 
				     + StringTools.replace(text, "\n", "\r\n\t") 
					 + "\r\n";
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

#end
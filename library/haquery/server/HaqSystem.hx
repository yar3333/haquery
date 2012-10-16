package haquery.server;

#if php
private typedef NativeLib = php.Lib;
private typedef NativeWeb = php.Web;
#elseif neko
private typedef NativeLib = neko.Lib;
private typedef NativeWeb = neko.Web;
#end

import haquery.common.HaqDefines;
import sys.io.File;
import sys.io.Process;
import sys.net.Host;
import sys.net.Socket;
import sys.net.WebSocket;
using haquery.StringTools;

class HaqSystem 
{
	public static var listener(default, null) : HaqWebsocketListener;
	
	public static function run(command:String)
	{
		var system = new HaqSystem();
		
		switch (command)
		{
			case "haquery-flush":
				system.doFlushCommnd();
				
			case "haquery-listener":
				system.doListenerCommand();
			
			case "haquery-status":
				system.doStatusCommand();
			
			case "haquery-status-log":
				system.doStatusLogCommand();
			
			case "haquery-status-listeners":
				system.doStatusListenersCommand();
			
			default:
				NativeLib.println("Unknow system command '" + command + "'.");
		}
	}
	
	function new() {}
	
	function doFlushCommnd()
	{
		NativeLib.println("<b>HAQUERY FLUSH</b><br /><br />");
		var path = HaqDefines.folders.temp;
		
		NativeLib.println("delete '" + path + "/haquery.log" + "'<br />");
		FileSystem.deleteFile(path + "/haquery.log");
		
		NativeLib.println("delete '" + path + "/cache" + "'<br />");
		FileSystem.deleteDirectory(path + "/cache");
		
		NativeLib.println("delete '" + path + "/templates" + "'<br />");
		FileSystem.deleteDirectory(path + "/templates");
	}
	
	function doListenerCommand()
	{
		if (Lib.isCli())
		{
			var args = Sys.args();
			if (args.length >= 2)
			{
				switch (args[1])
				{
					case "run":
						if (args.length >= 3)
						{
							var name = args[2];
							listener = Lib.config.listeners.get(name);
							if (listener == null) throw "Unknow listener '" + name + "'.";
							listener.run();
						}

					case "start":
						if (args.length >= 3)
						{
							var name = args[2];
							if (!Lib.config.listeners.exists(name)) throw "Unknow listener '" + name + "'.";
							var p = Lib.config.listeners.get(name).start();
							NativeLib.println("Listener '" + name + "' PID: " + p.getPid());
						}
					
					case "stop":
						if (args.length >= 3)
						{
							var name = args[2];
							var listener = Lib.config.listeners.get(name);
							if (listener == null) throw "Unknow listener '" + name + "'.";
							listener.stop();
						}
					
					default:
						NativeLib.println("Unknow <listener_command>. Supported: 'run', 'start' and 'stop'.");
				}
			}
			else
			{
				NativeLib.println("Need arguments: <listener_command> [listener_name].");
			}
		}
		else
		{
			NativeLib.println("This command allowed from the command-line only.");
		}
	}
	
	function isAdmin() : Bool
	{
		return Lib.config.secret != null 
			&& Lib.config.secret != "" 
			&& NativeWeb.getCookies().get("haquery_secret") == Lib.config.secret;
	}
	
	function doStatusCommand()
	{
		var html = new HaqSystemHtml();
		
		if (isAdmin())
		{
			html.bold("HaQuery")
				.content(" | <input type='button' value='Logout' onclick='setCookie(\"haquery_secret\", \"\", 0); window.location.reload(true);' /><br />\n")
				.js("updateLogTimeout = 1000;")
				.js("updateListenersTimeout = 5000;")
				.js("function updateLog() { $('#log').load('/haquery-status-log/', function() { setTimeout(updateLog, updateLogTimeout); });  }")
				.js("function updateListeners() { $('#listeners').load('/haquery-status-listeners/', function() { setTimeout(updateListeners, updateListenersTimeout); });  }")
				.js("setTimeout(updateLog, updateLogTimeout);")
				.js("setTimeout(updateListeners, updateListenersTimeout);")
				.begin("pre", "id='listeners' style='margin-top:5px; position:absolute; right:0; background: #eee'").end()
				.begin("pre", "id='log' style='margin-top:5px'").end();
		}
		else
		{
			html.begin("form", "id='form' method='post'")
				.content("To access HaQuery status and control enter the secret:")
				.content("<input type='text' id='secret' />")
				.content('<input type="button" value="OK" onclick="setCookie(\'haquery_secret\', $(\'#secret\').val(), 1000); $(\'#form\')[0].submit();" />')
				.end;
		}
		
		NativeLib.println(html);
	}
	
	function doStatusLogCommand()
	{
		var html = "";
		if (isAdmin())
		{
			var logLines = File.getContent(HaqDefines.folders.temp + "/haquery.log").split("\n");
			for (i in Std.max(0, logLines.length - 50)...logLines.length)
			{
				html += StringTools.htmlEscape(logLines[i]) + "\n";
			}
		}
		else
		{
			html += "Access denided, please reload a page.";
		}
		
		NativeLib.println(html);
	}
	
	function doStatusListenersCommand()
	{
		var html = "";
		
		if (isAdmin())
		{
			for (listener in Lib.config.listeners)
			{
				var status = listener.status();
				html += "<fieldset style='display:inline-block'>"
							+ "<legend>" + listener.name + "</legend>"
							+ (status != null ? status : "not run")
					  + "</fieldset>";
			}
		}
		else
		{
			html += "Access denided, please reload a page.";
		}
	
		NativeLib.println(html);
	}
}
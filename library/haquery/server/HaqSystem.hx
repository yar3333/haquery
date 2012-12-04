package haquery.server;

#if php
private typedef NativeLib = php.Lib;
private typedef NativeWeb = php.Web;
#elseif neko
private typedef NativeLib = neko.Lib;
private typedef NativeWeb = neko.Web;
#end

import haquery.common.HaqDefines;
import haxe.Serializer;
import sys.io.File;
import sys.io.FileSeek;
import sys.io.Process;
import sys.net.Host;
import sys.net.Socket;
import sys.net.WebSocket;
import haquery.Std;
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
			
			case "haquery-upload":
				system.doUploadCommand();
			
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
						else
						{
							for (listener in Lib.config.listeners)
							{
								var p = listener.start();
								NativeLib.println("Listener '" + listener.name + "' PID: " + p.getPid());
							}
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
			&& NativeWeb.getCookies().get("haquery_secret") == Lib.config.secret.urlEncode();
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
				.begin("table", "width='100%' border='0' style='border-collapse:collapse; margin-top:5px'")
					.begin("tbody")
						.begin("tr valign='top'")
							.begin("td")
								.begin("pre", "id='log' style='overflow-x:scroll'").end()
							.end()
							.begin("td width='200px'")
								.begin("div", "id='listeners'").end()
							.end()
						.end()
					.end()
				.end();
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
			var f = File.read(HaqDefines.folders.temp + "/haquery.log");
			f.seek(0, FileSeek.SeekEnd);
			var size = f.tell();
			f.seek(Std.max(0, size - 65536), FileSeek.SeekBegin);
			var logLines = f.readAll().toString().split("\n");
			f.close();
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
			var listeners = Lambda.array(Lib.config.listeners);
			listeners.sort(function(a, b) return a.name < b.name ? -1 : (a.name > b.name ? 1 : 0));
			for (listener in listeners)
			{
				var status = listener.status();
				html += "<fieldset style='background:#eee; margin-bottom:5px'>"
							+ "<legend>" + listener.name + "</legend>"
							+ (status != null ? status.replace("\n", "<br/>") : "not run")
					  + "</fieldset>";
			}
		}
		else
		{
			html += "Access denided, please reload a page.";
		}
	
		NativeLib.println(html);
	}
	
	function doUploadCommand()
	{
		if (!Lib.isCli())
		{
			var uploadsDir = NativeWeb.getCwd().rtrim("/") + "/" + HaqDefines.folders.temp + "/uploads";
			FileSystem.createDirectory(uploadsDir);
			NativeWeb.setHeader("Content-Type", "text/plain; charset=utf-8");
			var files = Lib.uploads.upload();
			NativeLib.println(Serializer.run(files));
		}
		else
		{
			NativeLib.println("This command allowed from the web request only.");
		}
	}
}

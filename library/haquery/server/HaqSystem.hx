package haquery.server;

import haquery.common.Generated;
import haquery.common.HaqDefines;
import haxe.Serializer;
import stdlib.FileSystem;
import stdlib.Std;
import sys.io.File;
import sys.io.FileSeek;
using stdlib.StringTools;

class HaqSystem 
{
	var config : HaqConfig;
	
	function new(config:HaqConfig)
	{
		this.config = config;
	}
	
	public static function run(command:String, config:HaqConfig)
	{
		var system = new HaqSystem(config);
		
		switch (command)
		{
			case "haquery-status":
				system.doStatusCommand();
			
			case "haquery-status-log":
				system.doStatusLogCommand();
			
			case "haquery-upload":
				system.doUploadCommand();
			
			default:
				Sys.println("Unknow system command '" + command + "'.");
		}
	}
	
	function isAdmin() : Bool
	{
		return config.secret != null 
			&& config.secret != "" 
			&& Web.getCookies().get("haquery_secret") == config.secret.urlEncode();
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
				.js("function updateLog() { $('#log').load('" + Generated.staticUrlPrefix + "/haquery-status-log/', function() { setTimeout(updateLog, updateLogTimeout); });  }")
				.js("setTimeout(updateLog, updateLogTimeout);")
				.begin("table", "width='100%' border='0' style='border-collapse:collapse; margin-top:5px'")
					.begin("tbody")
						.begin("tr valign='top'")
							.begin("td")
								.begin("pre", "id='log' style='overflow-x:scroll'").end()
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
		
		Sys.println(html);
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
		Sys.println(html);
	}
	
	function doUploadCommand()
	{
		var uploadsDir = Web.getCwd().rtrim("/") + "/" + HaqDefines.folders.temp + "/uploads";
		FileSystem.createDirectory(uploadsDir);
		Web.setHeader("Content-Type", "text/plain; charset=utf-8");
		var files = Lib.uploads.upload();
		Sys.println(Serializer.run(files));
	}
}

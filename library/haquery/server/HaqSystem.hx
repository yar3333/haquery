package haquery.server;

#if php
private typedef NativeLib = php.Lib;
#elseif neko
private typedef NativeLib = neko.Lib;
#end

import haquery.common.HaqDefines;
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
							var p = startListener(args[2]);
							NativeLib.println("Listener '" + args[2] + "' PID: " + p.getPid());
						}
					
					case "stop":
						if (args.length >= 3)
						{
							var name = args[2];
							var listener = Lib.config.listeners.get(name);
							if (listener == null) throw "Unknow listener '" + name + "'.";
							listener.stop();
						}
					
					case "status":
						if (args.length >= 3)
						{
							var name = args[2];
							var listener = Lib.config.listeners.get(name);
							if (listener == null) throw "Unknow listener '" + name + "'.";
							var status = listener.status();
							NativeLib.println(status != null ? status : "not run");
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
	
	function doStatusCommand()
	{
		var s = bold("[ Listeners ]") + "\n";
		for (listener in Lib.config.listeners)
		{
			s += "* " + listener.name + "\n";
			var status = listener.status();
			s += status != null ? status : "not run";
		}
		NativeLib.println(s.replace("\n", "<br />"));
	}
	
	function bold(s)
	{
		return Lib.isCli() ? s : "<b>" + s + "</b>";
	}
	
	public static function startListener(name:String) : Process
	{
		if (!Lib.config.listeners.exists(name)) throw "Unknow listener '" + name + "'.";
		return new Process("neko", [ "index.n", "haquery-listener", name, "run" ]);
	}
}
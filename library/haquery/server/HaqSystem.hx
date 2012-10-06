package haquery.server;

#if php
private typedef NativeLib = php.Lib;
#elseif neko
private typedef NativeLib = neko.Lib;
#end

import haquery.common.HaqDefines;

class HaqSystem 
{
	public static function run(command:String)
	{
		var system = new HaqSystem();
		
		switch (command)
		{
			case "haquery-flush":
				system.flush();
				
			case "haquery-listener":
				system.listener();
			
			default:
				NativeLib.println("Unknow system command '" + command + "'.");
		}
	}
	
	function new() {}
	
	function flush()
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
	
	function listener()
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
							var listener = Lib.config.listeners.get(name);
							if (listener == null) throw "Unknow listener '" + name + "'.";
							listener.run();
						}

					case "start":
						if (args.length >= 3)
						{
							var name = args[2];
							if (!Lib.config.listeners.exists(name)) throw "Unknow listener '" + name + "'.";
							var p = new sys.io.Process("neko", [ "index.n", "haquery-listener", name, "run" ]);
							NativeLib.println("Listener '" + name + "' PID: " + p.getPid());
						}
					
					case "stop":
						if (args.length >= 3)
						{
							var name = args[2];
							if (!Lib.config.listeners.exists(name)) throw "Unknow listener '" + name + "'.";
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
}
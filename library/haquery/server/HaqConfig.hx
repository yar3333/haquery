package haquery.server;

#if server

import stdlib.Std;
import stdlib.Exception;
import stdlib.FileSystem;
import haxe.htmlparser.HtmlDocument;
import haxe.htmlparser.HtmlNodeElement;
import sys.io.File;
using stdlib.StringTools;

class HaqConfig
{
	static var cache : Map<String,{ lastModTime:Float, config:HaqConfig }>;

    /**
     * Log only if access from specified IP.
     */
    public var filterTracesByIP(default, null) : String;
	
	/**
	 * -1 = no profiling, 0 - summary only, >0 - also nested report
	 */
	public var profilingLevel = -1;
	
	public var logSystemCalls = false;
	
	/**
	 * Write to log call with greater cpu using (in seconds).
	 */
	public var logSlowSystemCalls = 0.0;
	
	/**
     * User-defined data.
     */
    public var customs(default, null) : Map<String,Dynamic>;
	
	/**
	 * Default is 16M.
	 */
	public var maxPostSize(default, null) : Int;
	
	public var secret : String;
	
	function new(path:String)
	{
		maxPostSize = 16 * 1024 * 1024;
		filterTracesByIP = "";
		customs = new Map<String,Dynamic>();
		
		if (FileSystem.exists(path))
		{
			var xml = new HtmlDocument(File.getContent(path));
			
			for (node in xml.find(">config>param"))
			{
				if (node.hasAttribute("name") && node.hasAttribute("value"))
				{
					var name = node.getAttribute("name");
					var value = node.getAttribute("value");
					
					switch (name)
					{
						case "maxPostSize":
							maxPostSize = Std.parseInt(value);
						
						case "profilingLevel":
							profilingLevel = Std.parseInt(value);
						
						case "logSystemCalls":
							logSystemCalls = Std.bool(value);
						
						case "logSlowSystemCalls":
							logSlowSystemCalls = Std.parseFloat(value);
						
						case "filterTracesByIP":
							filterTracesByIP = value;
						
						case "secret":
							secret = value;
						
						default:
							throwBadConfigFileRecord(path, node);
					}
				}
				else
				{
					throwBadConfigFileRecord(path, node);
				}
			}
			
			for (node in xml.find(">config>custom"))
			{
				if (node.hasAttribute("name") && node.hasAttribute("value"))
				{
					customs.set(node.getAttribute("name"), Std.parseValue(node.getAttribute("value")));
				}
			}
		}
	}
	
    public static function load(path:String) : HaqConfig
	{
		if (cache == null) cache = new Map<String,{ lastModTime:Float, config:HaqConfig }>();
		
		var item = cache.get(path);
		if (item == null || FileSystem.exists(path) && item.lastModTime != FileSystem.stat(path).mtime.getTime())
		{
			var config = new HaqConfig(path);
			cache.set(path, { lastModTime:FileSystem.exists(path) ? FileSystem.stat(path).mtime.getTime() : 0, config:config });
			return config;
		}
		return item.config;
	}
	
	function throwBadConfigFileRecord(path:String, node:HtmlNodeElement) : Void
	{
		throw new Exception("HAQUERY ERROR: Bad config file ('" + path + "') record ('" + node.toString() + "').");
	}
}

#end
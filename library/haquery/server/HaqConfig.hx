package haquery.server;

#if server

import stdlib.Std;
import stdlib.Exception;
import stdlib.FileSystem;
import stdlib.Regex;
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
    public var filterTracesByIP(default, null) = "";
	
	/**
	 * -1 = no profiling, 0 - summary only, >0 - also nested report
	 */
	public var profilingLevel = -1;
	
	public var profilingResultsWidth = 120;
	
	public var logSystemCalls = false;
	
	/**
	 * Write to log call with greater cpu using (in seconds).
	 */
	public var logSlowSystemCalls = -1.0;
	
	/**
     * User-defined data.
     */
    public var customs(default, null) : Map<String,Dynamic>;
	
	/**
	 * Default is 16M.
	 */
	public var maxPostSize(default, null) = 16 * 1024 * 1024;
	
	/**
	 * Default is 16M.
	 */
	public var cacheSize = 16 * 1024 * 1024;
	
	public var urlRewriteRegex : Array<Regex>;
	
	public var secret : String;
	
	function new(path:String)
	{
		customs = new Map<String,Dynamic>();
		urlRewriteRegex = [];
		
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
							
						case "profilingResultsWidth":
							profilingResultsWidth = Std.parseInt(value);
							
						case "logSystemCalls":
							logSystemCalls = Std.bool(value);
							
						case "logSlowSystemCalls":
							logSlowSystemCalls = Std.parseFloat(value);
							
						case "filterTracesByIP":
							filterTracesByIP = value;
							
						case "cacheSize":
							cacheSize = Std.parseInt(value);
							
						case "urlRewriteRegex":
							urlRewriteRegex.push(new Regex(value));
							
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
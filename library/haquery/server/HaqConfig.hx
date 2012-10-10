package haquery.server;

import haquery.Exception;
import haxe.htmlparser.HtmlDocument;
import haxe.htmlparser.HtmlNodeElement;
import haquery.server.db.HaqDb;
import haquery.Std;
import sys.io.File;
using haquery.StringTools;

class HaqConfig
{
	/**
     * Database connection string in TYPE://USER:PASS@HOST/DBNAME form.
	 * For example: mysql://root:123456@localhost/mytestdb 
     */
	public var databaseConnectionString : String = null;
	
	/**
	 * Default is 16M.
	 */
	public var maxPostSize = 16 * 1024 * 1024;
	
    /**
     * Level of tracing SQL:
	 * 0 - show errors only;
	 * 1 - show queries;
	 * 2 - show queries and times.
     */
    public var sqlLogLevel = 0;

    public var enableProfiling = false;
	
	/**
     * Trace when components renders.
     */
    public var isTraceComponent = false;

    /**
     * Log only if access from specified IP.
     */
    public var filterTracesByIP = "";

	/**
     * User-defined data.
     */
    public var customs : Hash<Dynamic>;
	
	public var listeners : Hash<HaqWebsocketListener>;
	
	public function new(filePath:String)
	{
		customs = new Hash<Dynamic>();
		listeners = new Hash<HaqWebsocketListener>();
		
		load(filePath);
	}
	
    public function load(path:String) : Void
	{
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
						case "databaseConnectionString":
							databaseConnectionString = value;
						
						case "maxPostSize":
							maxPostSize = Std.parseInt(value);
						
						case "sqlLogLevel":
							sqlLogLevel = Std.parseInt(value);
						
						case "enableProfiling":
							enableProfiling = Std.bool(value);
						
						case "isTraceComponent":
							isTraceComponent = Std.bool(value);
						
						case "filterTracesByIP":
							filterTracesByIP = value;
						
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
			
			for (node in xml.find(">config>listeners>websocket"))
			{
				if (node.hasAttribute("name") && node.hasAttribute("host") && node.hasAttribute("port"))
				{
					var name = node.getAttribute("name");
					listeners.set(name, new HaqWebsocketListener(
						  name
						, node.getAttribute("host")
						, Std.parseInt(node.getAttribute("port"), 20000)
						, Std.bool(node.getAttribute("autorun"))
					));
				}
			}
		}
	}
	
	function throwBadConfigFileRecord(path:String, node:HtmlNodeElement) : Void
	{
		throw new Exception("HAQUERY ERROR: Bad config file ('" + path + "') record ('" + node + "').");
	}
}

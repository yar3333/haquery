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
	
	/**
	 * Change this field to your class instance, if you want to substitute components templates.
	 */
	public var templateSelector : HaqTemplateSelector;
	
	public var daemons : Hash<{ host:String, port:Int, autorun:Bool }>;
	
	public function new(filePath:String)
	{
		customs = new Hash<Dynamic>();
		templateSelector = new HaqTemplateSelector();
		daemons = new Hash<{ host:String, port:Int, autorun:Bool }>();
		
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
			
			for (node in xml.find(">config>daemons>listener"))
			{
				if (node.hasAttribute("port"))
				{
					daemons.set(node.getAttribute("name"), { 
						  host: node.getAttribute("host")
						, port: Std.parseInt(node.getAttribute("port"), 20000)
						, autorun: Std.bool(node.getAttribute("autorun"))
					});
				}
			}
		}
	}
	
	function throwBadConfigFileRecord(path:String, node:HtmlNodeElement) : Void
	{
		throw new Exception("HAQUERY ERROR: Bad config file ('" + path + "') record ('" + node + "').");
	}
}

package haquery.server;

import haxe.htmlparser.HtmlDocument;
import haquery.server.io.File;
import haquery.server.db.HaqDb;
import haquery.Std;
import haxe.htmlparser.HtmlNodeElement;

using haquery.StringTools;

class HaqConfig
{
	/**
     * Database connection string in TYPE://USER:PASS@HOST/DBNAME form.
	 * For example: mysql://root:123456@localhost/mytestdb 
     */
	public var databaseConnectionString : String;
	
	/**
	 * Default is 16M.
	 */
	public var maxPostSize : Int;
	
	/**
	 * Append file last modification timestamp to URLs. Set to "false" on production.
	 */
	public var isProtectFilesFromCaching : Bool;

    /**
     * Level of tracing SQL:
     * 0 - do not show anything;
     * 1 - show errors;
     * 2 - show queries too;
     * 3 - show queries too and results statuses.
     */
    public var sqlLogLevel(sqlLogLevel_getter, sqlLogLevel_setter) : SqlLogLevel;

    /**
     * Trace when components renders.
     */
    public var isTraceComponent : Bool;

    /**
     * Log only if access from specified IP.
     */
    public var filterTracesByIP : String;

	/**
     * User-defined data.
     */
    public var customs : Hash<Dynamic>;
	
	/**
	 * Change this field to your class instance, if you want to substitute components templates.
	 */
	public var templateSelector : HaqTemplateSelector;
	
	public var onStart : Void->Void;
	public var onFinish : Void->Void;
	
	inline function sqlLogLevel_getter() : SqlLogLevel { return HaqDb.logLevel; }
	inline function sqlLogLevel_setter(level:SqlLogLevel) { HaqDb.logLevel = level; return level; }
	
	public function new(filePath:String)
	{
		databaseConnectionString = null;
		maxPostSize = 16 * 1024 * 1024;
		isProtectFilesFromCaching = true;
		sqlLogLevel = SqlLogLevel.ERRORS;
		isTraceComponent = false;
		filterTracesByIP = '';
		customs = new Hash<Dynamic>();
		templateSelector = new HaqTemplateSelector();
		
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
					
					switch (node.getAttribute("name"))
					{
						case "databaseConnectionString":
							databaseConnectionString = value;
						
						case "maxPostSize":
							maxPostSize = Std.parseInt(value);
						
						case "isProtectFilesFromCaching":
							isProtectFilesFromCaching = Std.bool(value);
						
						case "sqlLogLevel":
							sqlLogLevel = Type.createEnum(SqlLogLevel, value);
						
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
		}
	}
	
	function throwBadConfigFileRecord(path:String, node:HtmlNodeElement) : Void
	{
		throw "HAQUERY ERROR: Bad config file ('" + path + "') record ('" + node + "').";
	}
}

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
    public var sqlLogLevel : LogLevel;

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
    public var custom : Hash<Dynamic>;
	
	/**
	 * Change this field to your class instance, if you want to substitute components templates.
	 */
	public var templateSelector : HaqTemplateSelector;
	
	public var onStart : Void->Void;
	public var onFinish : Void->Void;
	
	public function new(filePath:String)
	{
		databaseConnectionString = null;
		maxPostSize = 16 * 1024 * 1024;
		isProtectFilesFromCaching = true;
		sqlLogLevel = LogLevel.ERRORS;
		isTraceComponent = false;
		filterTracesByIP = '';
		custom = new Hash<Dynamic>();
		templateSelector = new HaqTemplateSelector();
		
		load(filePath);
	}
	
    public function load(path:String) : Void
	{
		if (FileSystem.exists(path))
		{
			var xml = new HtmlDocument(File.getContent(path));
			
			var paramNodes = xml.find(">config>param");
			for (node in paramNodes)
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
							sqlLogLevel = Type.createEnum(LogLevel, value);
						
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
			
			var customNodes = xml.find(">config>custom");
			for (node in customNodes)
			{
				if (node.hasAttribute("name") && node.hasAttribute("value"))
				{
					var value : Dynamic = node.getAttribute("value");
					var valueLC = value != null ? value.toLowerCase() : null;
					
					if (valueLC == "true") value = true;
					else
					if (valueLC == "false") value = false;
					else
					if (valueLC == "null") value = null;
					else
					if (~/^\s*[+-]?\s*(?:0x)?\d{1,9}\s*$/.match(valueLC)) value = Std.parseInt(value);
					else
					if (~/^\s*[+-]?\s*\d{1,9}(?:[.]\d{1,9})?(?:e[+-]?\d{1,9})?\s*$/.match(valueLC)) value = Std.parseFloat(value);
					
					custom.set(node.getAttribute("name"), value);
				}
			}
		}
	}
	
	function throwBadConfigFileRecord(path:String, node:HtmlNodeElement) : Void
	{
		throw "HAQUERY ERROR: Bad config file ('" + path + "') record ('" + node + "').";
	}
}

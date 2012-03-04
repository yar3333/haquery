package haquery.server;

import haxe.htmlparser.HtmlDocument;
import haquery.server.io.File;

using haquery.StringTools;

class HaqConfig
{
	/**
     * Database connection string in TYPE://USER:PASS@HOST/DBNAME form.
	 * For example: mysql://root:123456@localhost/mytestdb 
     */
	public var databaseConnectionString : String;

    /**
     * Level of tracing SQL:
     * 0 - do not show anything;
     * 1 - show errors;
     * 2 - show queries too;
     * 3 - show queries too and results statuses.
     */
    public var sqlTraceLevel : Int;

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
    
	public function new()
	{
		databaseConnectionString = readDatabaseConnectionString("config.xml");
		sqlTraceLevel = 1;
		isTraceComponent = false;
		filterTracesByIP = '';
		custom = new Hash<Dynamic>();
		templateSelector = new HaqTemplateSelector();
	}
	
    public static function readDatabaseConnectionString(path) : String
	{
		if (FileSystem.exists(path))
		{
			var xml = new HtmlDocument(File.getContent(path));
			var nodes = xml.find(">config>database");
			if (nodes.length > 0 && nodes[0].hasAttribute("connectionString"))
			{
				return nodes[0].getAttribute("connectionString");
			}
		}
		return null;
	}
}

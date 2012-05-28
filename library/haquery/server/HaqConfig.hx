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
    
	public var onStart : Void->Void;
	public var onFinish : Void->Void;
	
	public function new()
	{
		databaseConnectionString = null;
		sqlTraceLevel = 1;
		isTraceComponent = false;
		filterTracesByIP = '';
		custom = new Hash<Dynamic>();
		templateSelector = new HaqTemplateSelector();
		
		load("config.xml");
	}
	
    function load(path:String) : Void
	{
		if (FileSystem.exists(path))
		{
			var xml = new HtmlDocument(File.getContent(path));
			
			var databaseNodes = xml.find(">config>database");
			if (databaseNodes.length > 0 && databaseNodes[0].hasAttribute("connectionString"))
			{
				databaseConnectionString = databaseNodes[0].getAttribute("connectionString");
			}
			
			var customNodes = xml.find(">config>custom");
			for (customNode in customNodes)
			{
				if (customNode.hasAttribute("name") && customNode.hasAttribute("value"))
				{
					var value : Dynamic = customNode.getAttribute("value");
					if (value.toLowerCase() == "true") value = true;
					else
					if (value.toLowerCase() == "false") value = false;
					else
					if (value.toLowerCase() == "null") value = null;
					else
					if (value == "0") value = 0;
					else
					if (Std.parseInt(value) != null && Std.parseInt(value) != 0) value = Std.parseInt(value);
					else
					if (Std.parseFloat(value) != null && Std.parseFloat(value) != 0.0) value = Std.parseFloat(value);
					
					custom.set(customNode.getAttribute("name"), value);
				}
			}
		}
	}
}

package haquery.server;

import haquery.server.HaqXml;

using haquery.StringTools;

class HaqConfig
{
    public var db : { type:String, host:String, user:String, pass:String, database:String };
	
	public var autoSessionStart : Bool;

    public var autoDatabaseConnect : Bool;

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
     * Log only for users from IP.
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
    
	public function new() : Void
	{
		db = {
			 type : null
			,host : null
			,user : null
			,pass : null
			,database : null
		};
		autoSessionStart = true;
		autoDatabaseConnect = true;
		sqlTraceLevel = 1;
		isTraceComponent = false;
		filterTracesByIP = '';
		custom = new Hash<Dynamic>();
		templateSelector = new HaqTemplateSelector();
	}
}

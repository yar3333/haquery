#if php
package haquery.server;

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
    public var customData : Hash<Dynamic>;

	var componentsFolders : Array<String>;
    
    /**
     * Add components folder path.
     * @param path Path related to root site directory (without starting '/').
     */
    public function addComponentsFolder(path:String) : Void
    {
        componentsFolders.push(path.replace('\\', '/').trim('/'));
    }
    
    public function getComponentsFolders() : Array<String>
    {
        return componentsFolders;
    }
    
    /**
     * Path to layout file (null if layout not need).
     */
    public var layout : String;
	
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
		customData = new Hash<Dynamic>();
		componentsFolders = [ 'haquery/components' ];
        layout = null;
	}
}
#end

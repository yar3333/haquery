#if php
package haquery.server;

import php.FileSystem;
import php.io.File;
import php.NativeArray;
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
	 * Project-specific names of the component collections ( = subfolders in the components directory).
	 * HaQuery do finding components from the last added collection to the first.
	 */
	public var componentCollections(default, null) : Array<String>;
    
    /**
     * Path to layout file (null if layout not need).
     */
    public var layout : String;
    
    /**
     * Disable special CSS and JS inserts to your HTML pages.
     */
    public var disablePageMetaData : Bool;
	
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
		componentCollections = [ "haquery" ];
        layout = null;
        disablePageMetaData = false;
	}
}
#end

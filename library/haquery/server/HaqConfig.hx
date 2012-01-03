#if php
package haquery.server;

import php.FileSystem;
import php.io.File;
import php.NativeArray;

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

	/**
	 * Project-specific components package.
	 * Parent components package must be specified in config.xml file.
	 */
	public var componentsPackage : String;
    
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
		customData = new Hash<Dynamic>();
		componentsPackage = 'haquery.components';
        layout = null;
        disablePageMetaData = false;
	}
	
	static function getComponentsConfig(basePath:String, componentsPackage:String) : { extendsPackage : String }
	{
		var r = { extendsPackage : componentsPackage != "haquery.components" ? "haquery.components" : null };
		
		var configFilePath = componentsPackage.replace(".", "/") + "/config.xml";
		if (FileSystem.exists(basePath + configFilePath))
		{
			var text = File.getContent(basePath + configFilePath);
			var xml = Xml.parse(text);
			if (xml.firstElement().nodeName == "components")
			{
				for (elem in xml.firstElement().elements())
				{
					if (elem.nodeName == "extends")
					{
						if (elem.exists("package"))
						{
							r.extendsPackage = elem.get("package");
						}
					}
				}
			}
			
			/*var xml = new HaqXml(text);
			var nativeNodes : NativeArray = xml.find(">components>extends");
			if (nativeNodes != null)
			{
				var nodes : Array<HaqXmlNodeElement> = cast Lib.toHaxeArray(nativeNodes);
				if (nodes.length > 0)
				{
					if (nodes[0].hasAttribute("package"))
					{
						r.extendsPackage = nodes[0].getAttribute("package");
					}
				}
			}*/
		}
		return r;
	}
	
	public static function getComponentsFolders(basePath:String, componentsPackage:String) : Array<String>
	{
		if (basePath != "") basePath = basePath.replace('\\', '/').rtrim('/') + '/';
		
		var r : Array<String> = [];
		
		if (componentsPackage != null && componentsPackage != "")
		{
			var path = componentsPackage.replace(".", "/");
			if (!FileSystem.isDirectory(basePath + path))
			{
				throw "Components directory '" + path + "' do not exists.";
			}
			r.unshift(path + '/');
			
			var config = getComponentsConfig(basePath, componentsPackage);
			for (path in getComponentsFolders(basePath, config.extendsPackage))
			{
				r.unshift(path);
			}
		}
		
		return r;
	}
}
#end

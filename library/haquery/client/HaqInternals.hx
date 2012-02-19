#if js

package haquery.client;

class HaqInternals 
{
    /**
     * Setted by the server.
     */
	public static var pageFullTag(default, null) : String;
	
	/**
	 * Setted by the server.
	 * 
	 * fullTag => { 
	 * 					  config: [ extend, import_0, import_1, ... ]
	 * 					, ids: [ compID_0, compID_1, ... ]
	 * 					, serverHandlers: { 
	 * 											  elemID_0 => [ event_00, event_01, ... ]
	 * 											, elemID_1 => [ event_10, event_11, ... ]
	 * 											, ...
	 * 									  }
	 * 			  }
	 */
	static var components(default, null) : Hash<{ config:Array<String>, ids:Array<String>, serverHandlers:Hash<Array<String>> }>;
	
	static var componentIDs_cached : Hash<String>;
	
	/**
	 * @return componentID => fullTag
	 */
	public static function getComponentIDs() : Hash<String>
	{
		if (componentIDs_cached == null)
		{
			componentIDs_cached = new Hash<String>();
			for (fullTag in components.keys())
			{
				for (id in components.get(fullTag).ids)
				{
					componentIDs_cached.set(id, fullTag);
				}
			}
		}
		return componentIDs_cached;
	}
	
	public static function getServerHandlers(fullTag:String) : Hash<Array<String>>
	{
		return components.get(fullTag).serverHandlers;
	}
    
	public static function getTemplateConfig(fullTag:String) : HaqTemplateConfig
	{
		var component = components.get(fullTag);
		return { extend:component.config[0], imports:component.config.slice(1) };
	}
}

#end
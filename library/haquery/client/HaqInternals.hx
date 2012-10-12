package haquery.client;

import haquery.common.HaqSharedStorage;
import haxe.Unserializer;

@:keep @:expose class HaqInternals 
{
	/**
	 * Setted by the server.
	 * 
	 * fullTag => { 
	 * 					  config: [ extend, import_0, import_1, ... ]
	 * 					, serverHandlers: { 
	 * 											  elemID_0 => [ event_00, event_01, ... ]
	 * 											, elemID_1 => [ event_10, event_11, ... ]
	 * 											, ...
	 * 									  }
	 * 			  }
	 */
	public static var templates(default, null) : Hash<{ config:Array<String>, serverHandlers:Hash<Array<String>> }>;
	
	/**
	 * Setted by the server.
	 */
	static var tagIDs : Hash<Array<String>>;

	static var componentIDs_cached : Hash<String>;
	
	public static var sharedStorage(default, null) : HaqSharedStorage;
	
	public static var listener(default, null) : String;
	
	public static var pageKey(default, null) : String;
	public static var pageSecret(default, null) : String;
	
	/**
	 * @return componentID => fullTag
	 */
	public static function getComponentIDs() : Hash<String>
	{
		if (componentIDs_cached == null)
		{
			componentIDs_cached = new Hash<String>();
			for (fullTag in tagIDs.keys())
			{
				for (id in tagIDs.get(fullTag))
				{
					componentIDs_cached.set(id, fullTag);
				}
			}
		}
		return componentIDs_cached;
	}
	
	public static function getServerHandlers(fullTag:String) : Hash<Array<String>>
	{
		return templates.get(fullTag).serverHandlers;
	}
    
	public static function getTemplateConfig(fullTag:String) : HaqTemplateConfig
	{
		var component = templates.get(fullTag);
		var r = new HaqTemplateConfig();
		r.extend = component.config[0];
		r.imports = component.config.slice(1);
		return r;
	}
	
	public static function addComponent(fullTag:String, fullID:String)
	{
		getComponentIDs().set(fullID, fullTag);
	}
	
	static function unserialize(s:String) : String return Unserializer.run(s)
}

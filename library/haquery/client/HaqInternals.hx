package haquery.client;

import haquery.common.HaqSharedStorage;
import haxe.Unserializer;

@:keep @:expose class HaqInternals 
{
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
	
	public static function getServerHandlers(fullTag:String) : Array<String>
	{
		var clas = Type.getClass(fullTag + ".ConfigClient");
		return Reflect.field(clas, "serverHandlers");
	}
    
	public static function getTemplateConfig(fullTag:String) : HaqTemplateConfig
	{
		var clas = Type.getClass(fullTag + ".ConfigClient");
		return new HaqTemplateConfig(Reflect.field(clas, "extend"));
	}
	
	public static function addComponent(fullTag:String, fullID:String)
	{
		getComponentIDs().set(fullID, fullTag);
	}
	
	public static function isTemplateExist(fullTag:String)
	{
		var clas = Type.getClass(fullTag + ".ConfigClient");
		return clas != null;
	}
	
	static function unserialize(s:String) : String return Unserializer.run(s)
}

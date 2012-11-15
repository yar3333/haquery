package haquery.client;

import haquery.common.HaqSharedStorage;
import haquery.common.HaqTemplateExceptions;
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
	
	public static function addComponent(fullTag:String, fullID:String)
	{
		getComponentIDs().set(fullID, fullTag);
	}
	
	static function unserialize(s:String) : String return Unserializer.run(s)
}

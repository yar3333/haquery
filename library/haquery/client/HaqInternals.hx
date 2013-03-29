package haquery.client;

#if client

import haquery.common.HaqSharedStorage;
import haquery.common.HaqTemplateExceptions;
import haxe.Unserializer;

@:keep @:expose class HaqInternals 
{
	static var tagIDs : Dynamic;

	static var componentIDs_cached : Hash<String>;
	
	public static var sharedStorage(default, null) : HaqSharedStorage;
	
	/**
	 * @return componentID => fullTag
	 */
	public static function getComponentIDs() : Hash<String>
	{
		if (componentIDs_cached == null)
		{
			componentIDs_cached = new Hash<String>();
			for (fullTag in Reflect.fields(tagIDs))
			{
				for (id in cast(Reflect.field(tagIDs, fullTag), Array<Dynamic>))
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

#end
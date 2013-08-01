package haquery.client;

#if client

import haquery.common.HaqStorage;
import haxe.Unserializer;

@:keep @:expose class HaqInternals 
{
	/**
	 * componentID => fullTag
	 */
	public static var componentIDs(default, null) : Hash<String>;
	
	public static var storage(default, null) : HaqStorage;
	
	static function setTagIDs(tagIDs)
	{
		componentIDs = new Hash<String>();
		for (fullTag in Reflect.fields(tagIDs))
		{
			for (id in cast(Reflect.field(tagIDs, fullTag), Array<Dynamic>))
			{
				componentIDs.set(id, fullTag);
			}
		}
	}
	
	public static function addComponent(fullTag:String, fullID:String)
	{
		componentIDs.set(fullID, fullTag);
	}
	
	static function unserialize(s:String) : String return Unserializer.run(s)
}

#end
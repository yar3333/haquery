#if js

package haquery.client;

import haxe.Unserializer;
import js.Lib;
import js.Dom;

class HaqInternals 
{
	public static var templates(default, null) : Hash<HaqTemplate>;
	
    private static var tags : Array<Array<String>>;
	public static var id_tag(id_tag_getter, null) : Hash<String>;
	static var id_tag_cached : Hash<String>;
	static function id_tag_getter() : Hash<String>
	{
		if (id_tag_cached == null)
		{
			id_tag_cached = new Hash<String>();
			for (tagAndIDs in tags)
			{
				var tag = tagAndIDs[0];
				var ids : Array<String> = tagAndIDs[1].split(',');
				if (ids.length == 1 && ids[0] == '') ids = [];
				for (id in ids)
				{
					id_tag_cached.set(id, tag);
				}
			}
		}
		return id_tag_cached;
	}
    
	/**
	 * fullTag =>
	 */
    static var serializedServerHandlers : String;
	public static var serverHandlers(serverHandlers_getter, null) : Hash<Hash<Array<String>>>;
    static var serverHandlers_cached : Hash<Hash<Array<String>>>;
    static function serverHandlers_getter() : Hash<Hash<Array<String>>>
    {
        if (serverHandlers_cached == null)
        {
            serverHandlers_cached = Unserializer.run(serializedServerHandlers);
        }
        return serverHandlers_cached;
    }
    
    public static var pageFullID : String;
	
	
	
}

#end
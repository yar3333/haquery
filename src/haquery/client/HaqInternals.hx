package haquery.client;

import haxe.Unserializer;
import js.Lib;

class HaqInternals 
{
	public static inline var DELIMITER = '-';
	
    public static var componentsFolders : Array<String>;
	
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
				if (ids.length==1 && ids[0]=='') ids = [];
				for (id in ids) id_tag_cached.set(id, tag);
			}
		}
		return id_tag_cached;
	}
    
    static var serializedPageServerHandlers : String;
    public static var pageServerHandlers(pageServerHandlers_getter, null) : Hash<Array<String>>;
    static var pageServerHandlers_cached : Hash<Array<String>>;
    static function pageServerHandlers_getter() : Hash<Array<String>>
    {
        if (pageServerHandlers_cached == null)
        {
            pageServerHandlers_cached = Unserializer.run(serializedPageServerHandlers);
        }
        return pageServerHandlers_cached;
    }
	
    static var serializedComponentsServerHandlers : String;
    public static var componentsServerHandlers(componentsServerHandlers_getter, null) : Hash<Hash<Array<String>>>;
    static var componentsServerHandlers_cached : Hash<Hash<Array<String>>>;
    static function componentsServerHandlers_getter() : Hash<Hash<Array<String>>>
    {
        if (componentsServerHandlers_cached == null)
        {
            componentsServerHandlers_cached = Unserializer.run(serializedComponentsServerHandlers);
        }
        return componentsServerHandlers_cached;
    }
}
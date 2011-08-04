package haquery.client;

import js.Lib;

class HaqInternals 
{
	public static inline var DELIMITER = '-';
	
	public static var componentsFolders : Array<String>;
	public static var serverHandlers : Array<Array<Dynamic>>;
	static var tags : Array<Array<String>>;
	public static var lists : Array<Array<Dynamic>>; // [ [listID1,tag1,len1], [listID2,tag2,len2] ... ]
	
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
}
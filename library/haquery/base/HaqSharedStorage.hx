package haquery.base;

class HaqSharedStorage
{
    var data : Hash<Hash<Dynamic>>;
	
	public function new()
	{
		data = new Hash<Hash<Dynamic>>();
	}
	
	public function set(group:String, key:String, value:Dynamic)
	{
		if (!data.exists(group))
		{
			data.set(group, new Hash<Dynamic>());
		}
		data.get(group).set(key, value);
	}
	
	public function get(group:String, key:String) : Dynamic
	{
		if (data.exists(group))
		{
			return data.get(group).get(key);
		}
		return null;
	}
}
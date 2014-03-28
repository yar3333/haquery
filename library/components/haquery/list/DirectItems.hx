package components.haquery.list;

import stdlib.Debug;
import haquery.server.HaqComponent;

class DirectItems 
{
	var hash : Map<String,HaqComponent>;
	var list : Array<HaqComponent>;
	
	public function new() 
	{
		hash = new Map<String,HaqComponent>();
		list = [];
	}
	
	public function get(id:String) : HaqComponent
	{
		return hash.get(id);
	}
	
	public function set(id:String, com:HaqComponent) : Void
	{
		Debug.assert(!hash.exists(id), "factory item '" + id + "' already set.");
		
		hash.set(id, com);
		list.push(com);
	}
	
	public function exists(id:String) : Bool
	{
		return hash.exists(id);
	}
	
	public function iterator() : StdTypes.Iterator<HaqComponent>
	{
		return list.iterator();
	}
	
	public function remove(id:String) : Bool
	{
		if (hash.remove(id))
		{
			for (i in 0...list.length)
			{
				if (list[i].id == id)
				{
					list.splice(i, 1);
					break;
				}
			}
			return true;
		}
		return false;
	}
}

package components.haquery.list;

import stdlib.Std;
import haquery.server.HaqComponent;

class DirectItems 
{
	var hash : Hash<HaqComponent>;
	var list : Array<HaqComponent>;
	
	public function new() 
	{
		hash = new Hash<HaqComponent>();
		list = new Array<HaqComponent>();
	}
	
	public function get(id:String) : HaqComponent
	{
		return hash.get(id);
	}
	
	public function set(id:String, com:HaqComponent) : Void
	{
		Std.assert(!hash.exists(id), "factory item '" + id + "' already set.");
		
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
}

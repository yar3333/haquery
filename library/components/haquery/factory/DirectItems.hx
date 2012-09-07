package components.haquery.factory;

import haquery.server.Lib;
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
		Lib.assert(!hash.exists(id), "factory item '" + id + "' already set.");
		
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

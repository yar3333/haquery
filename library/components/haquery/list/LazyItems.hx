package components.haquery.list;

import haquery.server.HaqComponent;

class LazyItems 
{
	var hash : Map<String,HaqComponent>;
	var length : Int;
	var create : String->HaqComponent;
	
	public function new(length:Int, create:String->HaqComponent) 
	{
		hash = new Map<String,HaqComponent>();
		this.length = length;
		this.create = create;
	}
	
	public function get(id:String) : HaqComponent
	{
		if (!hash.exists(id))
		{
			hash.set(id, create(id));
		}
		return hash.get(id);
	}
	
	public function set(id:String, com:HaqComponent) : Void
	{
		hash.set(id, com);
	}
	
	public function exists(id:String) : Bool
	{
		return hash.exists(id);
	}
	
	public function iterator() : StdTypes.Iterator<HaqComponent>
	{
		return hash.iterator();
	}
	
	public function remove(id:String) : Bool
	{
		if (hash.remove(id))
		{
			length--;
			return true;
		}
		return false;
	}
}

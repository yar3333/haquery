package components.haquery.factory;

import haquery.server.Lib;
import haquery.server.HaqComponent;

private class LazyItemsIterator
{
	var length : Int;
	var items : LazyItems;
	
	var n = 0;
	
	public function new(length:Int, items:LazyItems)
	{
		this.length = length;
		this.items = items;
	}
	
	public function hasNext() : Bool
	{
		return n < length;
	}
	
	public function next() : HaqComponent
	{
		var r = items.get(Std.string(n));
		n++;
		return r;
	}
}

class LazyItems 
{
	var hash : Hash<HaqComponent>;
	var length : Int;
	var create : String->HaqComponent;
	
	public function new(length:Int, create:String->HaqComponent) 
	{
		hash = new Hash<HaqComponent>();
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
		return new LazyItemsIterator(length, this);
	}
}

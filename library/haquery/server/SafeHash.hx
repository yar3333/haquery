package haquery.server;

import neko.vm.Mutex;

class SafeHash<Data>
{
	var m : Mutex;
	var h : Hash<Data>;
	
	public function new() 
	{
		h = new Hash<Data>();
	}
	
	public function set(k:String, v:Data)
	{
		m.acquire();
		h.set(k, v);
		m.release();
	}
	
	public function get(k:String) : Data
	{
		m.acquire();
		var v = h.get(k);
		m.release();
		return v;
	}
	
	public function remove(k:String) : Void
	{
		m.acquire();
		h.remove(k);
		m.release();
	}
	
	public var length(get_length, null) : Int;
	
	function get_length()
	{
		m.acquire();
		var r = Lambda.count(h);
		m.release();
		return r;
	}
	
	public function keys() : Iterator<String>
	{
		m.acquire();
		var r = h.keys();
		m.release();
		return r;
	}
	
}
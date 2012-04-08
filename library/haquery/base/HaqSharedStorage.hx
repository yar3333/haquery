package haquery.base;

import haxe.Serializer;
import haxe.Unserializer;

enum SendDirection
{
	both;
	serverToClient;
	clientToServer;
}

private typedef Item =
{
	var v : Dynamic;
	var d : SendDirection;
}

class HaqSharedStorage
{
    var data : Hash<Hash<Item>>;
	
	public function new()
	{
		data = new Hash<Hash<Item>>();
	}
	
	public function set(group:String, key:String, value:Dynamic, direction:SendDirection)
	{
		if (!data.exists(group))
		{
			data.set(group, new Hash<Item>());
		}
		data.get(group).set(key, { v:value, d:direction });
	}
	
	public function get(group:String, key:String) : Dynamic
	{
		if (data.exists(group))
		{
			var item = data.get(group).get(key);
			return item != null ? item.v : null;
		}
		return null;
	}
	
	function hxSerialize(s:Serializer)
	{
		var r = new Hash<Hash<Item>>();
		for (group in data.keys())
		{
			var h = data.get(group);
			if (h.keys().hasNext())
			{
				r.set(group, h);
			}
		}
		s.serialize(r);
	}
	
	function hxUnserialize(s:Unserializer) 
	{
		data = s.unserialize();
    }
	
	function getHashForSerialize(h:Hash<Item>) : Hash<{v:Dynamic, d:SendDirection}>
	{
		var r = new Hash<{v:Dynamic, d:SendDirection}>();
		for (k in h.keys())
		{
			var item = h.get(k);
			if (item.d == SendDirection.both || item.d == #if (php || neko) SendDirection.serverToClient #elseif js SendDirection.clientToServer #end)
			{
				r.set(k, item);
			}
		}
		return r;
	}
}
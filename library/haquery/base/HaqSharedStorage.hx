package haquery.base;

import haxe.Serializer;

enum SendDirection
{
	both;
	serverToClient;
	clientToServer;
}

class HaqSharedStorage
{
    var data : Hash<Hash<{v:Dynamic, d:SendDirection}>>;
	
	public function new()
	{
		data = new Hash<Hash<{v:Dynamic, d:SendDirection}>>();
	}
	
	public function set(group:String, key:String, value:Dynamic, sendDirection:SendDirection)
	{
		if (!data.exists(group))
		{
			data.set(group, new Hash<{v:Dynamic, d:SendDirection}>());
		}
		data.get(group).set(key, {v:value, d:sendDirection});
	}
	
	public function get(group:String, key:String) : Dynamic
	{
		if (data.exists(group))
		{
			return data.get(group).get(key).v;
		}
		return null;
	}
	
	public function serialize() : String
	{
		var r = new Hash<Hash<Dynamic>>();
		for (group in data.keys())
		{
			var h = data.get(group);
			if (h.keys().hasNext())
			{
				r.set(group, h);
			}
			
		}
		return Serializer.run(r);
	}
	
	function getHashForSerialize(h:Hash<{v:Dynamic, d:SendDirection}>) : Hash<{v:Dynamic, d:SendDirection}>
	{
		var r = new Hash<{v:Dynamic, d:SendDirection}>();
		for (k in h.keys())
		{
			var v = h.get(k);
			if (v.d == SendDirection.both || v.d == #if (php || neko) SendDirection.serverToClient #elseif js SendDirection.clientToServer #end)
			{
				r.set(k, v);
			}
		}
		return r;
	}
}
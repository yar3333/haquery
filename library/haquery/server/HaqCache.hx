package haquery.server;

private typedef Object =
{
	var invalidate : Float;
	var size : Int;
	var data : Dynamic;
}

class HaqCache
{
	public var maxSize : Int;
	var cache : Map<String, Object>;
	var queue : Array<String>;
	
	var cacheSize = 0;
	
	var hits = 0;
	var miss = 0;
	
	public function new(maxSize:Int)
	{
		this.maxSize = maxSize;
		cache = new Map<String, Object>();
		queue = [];
	}
	
	public function get(key:String, period=1.0e100, ?predefinedDataSize:Int, getData:Void->Dynamic, ?onCacheHit:Dynamic->Void) : Dynamic
	{
		if (key == null) return getData();
		
		var now = Date.now().getTime();
		
		var cached = cache.exists(key);
		var obj = cached ? cache.get(key) : null;
		if (!cached || obj != null && obj.invalidate < now)
		{
			miss++;
			var invalidate = now + period;
			var data = getData();
			if (obj == null)
			{
				obj = {
					invalidate: invalidate,
					data: data,
					size: predefinedDataSize != null ? predefinedDataSize : getObjectSize(key, data)
				};
				cache.set(key, obj);
			}
			else
			{
				cacheSize -= obj.size;
				
				obj.invalidate = invalidate;
				obj.data = data;
				obj.size = predefinedDataSize != null ? predefinedDataSize : getObjectSize(key, data);
			}
			cacheSize += obj.size;
		}
		else
		{
			if (onCacheHit != null) onCacheHit(obj.data);
			hits++;
		}
		
		if (cached) queue.remove(key);
		queue.unshift(key);
		
		while (cacheSize > maxSize) remove(queue.pop());
		
		return obj.data;
	}
	
	public function remove(key:String)
	{
		if (cache.exists(key))
		{
			cacheSize -= cache.get(key).size;
			cache.remove(key);
			queue.remove(key);
		}
	}
	
	function getObjectSize(key:String, o:Dynamic) : Int
	{
		return 10 + key.length + stdlib.Serializer.run(o, true).length;
	}
	
	public function stat()
	{
		return
		{ 
			queueLength: queue.length,
			cacheLength: Lambda.count(cache),
			cacheSize: cacheSize,
			hits: hits,
			miss: miss
		};
	};
}
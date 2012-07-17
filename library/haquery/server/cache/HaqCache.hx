package haquery.server.cache;

#if neko
import haquery.Exception;
import memcached.Client;
#end

class HaqCache 
{
	var driver(default, null) : HaqCacheDriver;
	var keyPrefix = "";
	
	public var isActive(isActive_getter, null) : Bool;
	function isActive_getter() { return driver != null; }
	
	public function new(?connectionString:String)
	{
		if (connectionString != null)
		{
			var re = new EReg('^([a-z]+)\\://([_.a-zA-Z0-9]+)(?:[:](\\d+))?(?:/([-_.a-zA-Z0-9/]+)?)?$', '');
			if (!re.match(connectionString))
			{
				throw new Exception("Connection string invalid format. Example: 'memcached://localhost/mykeyprefix'.");
			}
			
			switch (re.matched(1))
			{
				#if neko
				case "memcached":
					if (re.matched(4) != null)
					{
						keyPrefix = re.matched(4);
					}
					driver = new HaqCacheDriver_memcached(re.matched(2), Std.parseInt(re.matched(3)));
				#end
				
				case "filesystem":
					driver = new HaqCacheDriver_filesystem(re.matched(2) + "/" + re.matched(4));
				
				default:
					throw new Exception("Cache driver '" + re.matched(1) + "' is not supported on this platform.");
			}
			
			if (keyPrefix != "")
			{
				keyPrefix += "-";
			}
		}
	}
	
	public function get(key:String, ?calc:Void->Dynamic) : Dynamic
	{
		if (driver != null)
		{
			var fullKey = keyPrefix + key;
			var r : Dynamic = null;
			try
			{
				r = driver.get(fullKey);
			}
			catch (e:Dynamic)
			{
				trace("HAQUERY CACHE bad cache data (" + e + ")");
				trace(driver.get(fullKey));
			}
			if (r == null && calc != null)
			{
				r = calc();
				driver.set(fullKey, r);
			}
			return r;
		}
		
		if (calc != null)
		{
			return calc();
		}
		
		throw new Exception("Cache is not initialized.");
	}
	
	public function set(key:String, value:Dynamic) : Void
	{
		driver.set(keyPrefix + key, value);
	}
	
	public function remove(key:String) : Void
	{
		driver.remove(keyPrefix + key);
	}
	
	public function removeAll()
	{
		driver.removeAll();
	}
	
	public function dispose() : Void
	{
		if (driver != null)
		{
			driver.dispose();
			driver = null;
		}
	}
}
package;

import haquery.server.HaqCache;

class CacheTest extends haxe.unit.TestCase
{
    public function testBasic()
    {
		var cache = new HaqCache(200);
		
		for (i in 0...50)
		{
			var id = Std.string(Std.random(50));
			cache.get(id, DateTools.seconds(2), function() return "t");
			//Sys.sleep(0.1);
		}
		
		//Sys.sleep(3);
		
		trace(cache.stat());
		
        this.assertEquals(1, 1);
    }
}

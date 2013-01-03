package haquery.server;

#if server

import haquery.StringTools;

private typedef HaqProfilerBlock =
{
    var count : Int;
    var dt : Float;
}

private typedef HaqProfilerOpened =
{
    var name : String;
    var time : Float;
}

private typedef HaqProfilerResult =
{
    var name : String;
    var dt : Float;
    var count: Int;
}

class HaqProfiler
{
    public var isActive(default, null) : Bool;
	
	var blocks : Hash<HaqProfilerBlock>;
    var opened : Array<HaqProfilerOpened>;

    public function new(isActive:Bool)
    {
        this.isActive = isActive;
		
		if (isActive)
		{
			blocks = new Hash<HaqProfilerBlock>();
			opened = [];
		}
    }
    
    public function begin(name:String) : Void
    {
        if (isActive)
		{
			if (opened.length > 0)
			{
				name = opened[opened.length - 1].name + '-' + name;
			}
			opened.push( { name:name, time:Sys.time() } );
		}
    }

    public function end() : Void
    {
        if (isActive)
		{
			haquery.server.Lib.assert(opened.length > 0);
			
			var b = opened.pop();
			var dt = Sys.time() - b.time;

			if (!blocks.exists(b.name))
			{
				blocks.set(b.name, { count:1, dt:dt });
			}
			else
			{
				blocks.get(b.name).count++;
				blocks.get(b.name).dt += dt;
			}
        }
    }

    public function traceResults(levelLimit = 4, traceWidth = 120)
    {
   		if (isActive)
		{
			trace("HAQUERY PROFILING Results");
			
			if (opened.length > 0)
			{
				for (b in opened)
				{
					trace("HAQUERY WARNING: Block '" + b.name + "' not ended");
				}
			}
			
			traceResultsNested(levelLimit, traceWidth);
			traceResultsSummary(traceWidth);
        }
    }
    
    function traceResultsNested(levelLimit:Int, traceWidth:Int)
    {
        var results = new Array<HaqProfilerResult>();
        for (name in blocks.keys()) 
        {
            var block = blocks.get(name);
            results.push( {
                 name: name
                ,dt: block.dt
                ,count: block.count
            });
        }
        
        results.sort(function(a, b)
        {
            var ai = a.name.split('-');
            var bi = b.name.split('-');
            
            for (i in 0...Std.int(Math.min(ai.length, bi.length)))
            {
                if (ai[i] != bi[i])
                {
                    return ai[i] < bi[i] ? -1 : 1;
                }
            }
            
            return Std.int((b.dt - a.dt) * 1000);
        });

        trace("HAQUERY PROFILING Nested:");
        traceGistogram(Lambda.filter(results, function(result) return result.name.split('-').length <= levelLimit), traceWidth);
    }

    function traceResultsSummary(traceWidth:Int)
    {
        var results = new Hash<HaqProfilerResult>();
		
        for (name in blocks.keys()) 
        {
            var block = blocks.get(name);
            var nameParts = name.split('-');
            name = nameParts[nameParts.length - 1];
            if (!results.exists(name))
            {
                results.set(name, { name:name, dt:0.0, count:0 });
            }
            results.get(name).dt += block.dt;
            results.get(name).count += block.count;
        }
        
        var values = Lambda.array(results);
        values.sort(function(a, b)
        {
            return Std.int((b.dt - a.dt) * 1000);
        });

        trace("HAQUERY PROFILING Summary:");
        traceGistogram(values, traceWidth);
    }
    
    function traceGistogram(results:Iterable<HaqProfilerResult>, traceWidth:Int)
    {
		var maxLen = 0;
		var maxDT = 0.0;
		var maxCount = 0;
		for (result in results) 
		{
			maxLen = Std.int(Math.max(maxLen, result.name.length));
			maxDT = Math.max(maxDT, result.dt);
			maxCount = Std.int(Math.max(maxCount, result.count));
		}
		
		var maxW = traceWidth - maxLen - Std.string(maxCount).length;
		if (maxW < 1) maxW = 1;
		
		for (result in results)
		{
			trace(
				 "HAQUERY "
				+StringTools.lpad(Std.string(Std.int(result.dt*1000)), "0", Std.string(Std.int(maxDT*1000)).length) + " | "
				+StringTools.rpad(StringTools.rpad('', '*', Math.round(result.dt / maxDT * maxW)), ' ', maxW)
				+" | " + StringTools.rpad(result.name, " ", maxLen)
				+" [" + StringTools.rpad(Std.string(result.count), " ", Std.string(maxCount).length) + " time(s)]"
			);
		}
    }
}

#end
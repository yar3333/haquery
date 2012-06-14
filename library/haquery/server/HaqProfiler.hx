package haquery.server;

import haquery.server.Sys;

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
    static inline var file = 'temp/profiler.data';
    static inline var traceWidth = 120;
    
    var blocks : Hash<HaqProfilerBlock>;
    var opened : Array<HaqProfilerOpened>;

    public function new()
    {
        #if PROFILER
        blocks = new Hash<HaqProfilerBlock>();
        opened = [];
        #end
    }
    
    public #if !PROFILER inline #end function begin(name:String) : Void
    {
        #if PROFILER
        if (opened.length > 0)
        {
            name = opened[opened.length - 1].name + '-' + name;
        }
        opened.push({ name:name, time:Sys.time() });
        #end
    }

    public #if !PROFILER inline #end function end() : Void
    {
        #if PROFILER
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
        #end
    }

    public #if !PROFILER inline #end function traceResults(levelLimit = 4)
    {
        #if PROFILER
        
        trace("HAQUERY Profiling Results");
        if (opened.length > 0)
        {
            for (b in opened)
            {
                trace("HAQUERY WARNING: Block '" + b.name + "' not ended");
            }
        }
        
        traceResultsNested(levelLimit);
        traceResultsSummary();
        
        #end
    }
    
    #if !PROFILER inline #end function traceResultsNested(levelLimit)
    {
        #if PROFILER
        
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
            
            return Math.round(b.dt - a.dt); 
        });

        trace("HAQUERY Nested:");
        traceGistogram(Lambda.filter(results, function(result) 
        {
            return result.name.split('-').length <= levelLimit;
        }));
        
        #end
    }

    #if !PROFILER inline #end function traceResultsSummary()
    {
        #if PROFILER
        
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
        
        var values = results.values();
        values.sort(function(a, b)
        {
            return Math.round(b.dt - a.dt); 
        });

        trace("HAQUERY Summary:");
        traceGistogram(values);
        
        #end
    }
    
    #if !PROFILER inline #end function traceGistogram(results:Iterable<HaqProfilerResult>)
    {
        #if PROFILER
        
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
                +StringTools.format("%0" + Std.string(Math.round(maxDT)).length + "d | ", Std.int(result.dt))
                +StringTools.rpad(StringTools.rpad('', '*', Math.round(result.dt / maxDT * maxW)), ' ', maxW)
                +StringTools.format(" | %-" + maxLen + "s", result.name)
                +StringTools.format(" [%-" + Std.string(maxCount).length + "d time(s)]", result.count)
            );
        }
        
        #end
    }
    
}


#if !client

package haquery.server.db;

import haquery.server.db.HaqDbDriver;
import haquery.server.db.HaqDbDriver_mysql;
import haquery.server.HaqProfiler;
import sys.db.ResultSet;

class HaqDb
{
    public var connection : HaqDbDriver = null;
	
    /**
     * Level of tracing SQL:
	 * 0 - show errors only;
	 * 1 - show queries;
	 * 2 - show queries and times.
     */
	public var logLevel : Int;
	
	public var profiler : HaqProfiler = null;
	
    public function new(connectionString:String, logLevel=0, ?profiler:HaqProfiler) : Void
    {
		var re = new EReg('^([a-z]+)\\://([_a-zA-Z0-9]+)\\:(.+?)@([-_.a-zA-Z0-9]+)(?:[:](\\d+))?/([-_a-zA-Z0-9]+)$', '');
		if (!re.match(connectionString))
		{
			throw "Connection string invalid format.";
		}
		
        if (profiler != null) profiler.begin("openDatabase");
            connection = Type.createInstance(
                 Type.resolveClass('haquery.server.db.HaqDbDriver_' + re.matched(1))
				,[ re.matched(4), re.matched(2), re.matched(3), re.matched(6), re.matched(5) != null && re.matched(5) != "" ? Std.parseInt(re.matched(5)) : 0 ]
            );
        if (profiler != null) profiler.end();
		
		this.logLevel = logLevel;
		this.profiler = profiler;
    }

    public function query(sql:String) : ResultSet
    {
		try
		{
			if (profiler != null) profiler.begin('SQL query');
			if (logLevel >= 1) trace("SQL QUERY: " + sql);
			var startTime = logLevel >= 2 ? Sys.time() : 0;
			var r = connection.query(sql);
			if (logLevel >= 2) trace("SQL QUERY FINISH " + Math.round((Sys.time() - startTime) * 1000) + " ms");
			if (profiler != null) profiler.end();
			return r;
		}
		catch (e:HaqDbException)
		{
            if (profiler != null) profiler.end();
			throw "SQL EXCEPTION:\n"
				+ "SQL QUERY: " + sql + "\n"
				+ "SQL RESULT: error code = " + e.code + " (" + e.message + ").";
		}
		catch (e:Dynamic)
		{
			if (profiler != null) profiler.end();
			throw e;
		}
    }

    public function quote(v:Dynamic) : String
    {
		return connection.quote(v);
    }

    public function lastInsertId() : Int
    {
        return connection.lastInsertId();
    }
	
	public function close() : Void
	{
		try { connection.close(); } 
		catch (e:Dynamic) {}
		connection = null;
	}
}

#end
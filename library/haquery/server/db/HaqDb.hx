package haquery.server.db;

import haquery.Exception;
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
			throw new Exception("Connection string invalid format.");
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

    public function query(sql:String, ?params:Dynamic) : ResultSet
    {
		try
		{
			if (profiler != null) profiler.begin('SQL query');
			if (params != null) sql = bind(sql, params);
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
			throw new Exception("DATABASE\n\tSQL QUERY: " + sql + "\n\tSQL RESULT: error code = " + e.code + ".", e);
		}
		catch (e:Dynamic)
		{
			if (profiler != null) profiler.end();
			Exception.rethrow(e);
			return null;
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
	
	public function bind(sql:String, params:Dynamic) : String
	{
		return new EReg("[{]([_a-zA-Z][_a-zA-Z0-9]*)[}]", "").customReplace(sql, function(re) 
		{
			var name = re.matched(1);
			if (Reflect.hasField(params, name))
			{
				return quote(Reflect.field(params, name));
			}
			throw "Param '" + name + "' not found while binding sql query '" + sql + "'.";
		});
	}
}

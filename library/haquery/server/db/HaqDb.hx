#if !client

package haquery.server.db;

import haquery.server.db.HaqDbDriver;
import haquery.server.db.HaqDbDriver_mysql;
import haquery.server.HaqProfiler;

#if php
import php.db.ResultSet;
#elseif neko
import neko.db.ResultSet;
#elseif cpp
import cpp.db.ResultSet;
#end

class HaqDb
{
    static public var connection : HaqDbDriver = null;
	
    /**
     * Level of tracing SQL:
	 * 0 - show errors only;
	 * 1 - show queries;
	 * 2 - show queries and times.
     */
	static public var logLevel = 0;
	
	static public var profiler : HaqProfiler = null;
	
    static public function connect(connectionString:String) : Bool
    {
		if (connection != null) return true;
		
		var re = new EReg('^([a-z]+)\\://([_a-zA-Z0-9]+)\\:(.+?)@([_.a-zA-Z0-9]+)(?:[:](\\d+))?/([_a-zA-Z0-9]+)$', '');
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
		
        return true;
    }

    static public function query(sql:String) : ResultSet
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

    static public function quote(v:Dynamic) : String
    {
		return connection.quote(v);
    }

    static public function lastInsertId() : Int
    {
        return connection.lastInsertId();
    }
}

#end
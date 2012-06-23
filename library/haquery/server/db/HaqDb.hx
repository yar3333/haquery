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

enum SqlLogLevel
{
	/**
	 * 0 - do not show anything.
	 */
	NONE;
	/**
	 * 1 - show errors.
	 */
	ERRORS;
	/**
	 * 2 - show queries too.
	 */
	QUERIES;
	/**
	 * 3 - show queries and results statuses.
	 */
	RESULTS;
}

class HaqDb
{
    static public var connection : HaqDbDriver = null;
	static public var logLevel = SqlLogLevel.NONE;
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
				,[ re.matched(4), re.matched(2), re.matched(3), re.matched(6), re.matched(5) != "" ? Std.parseInt(re.matched(5)) : 0 ]
            );
        if (profiler != null) profiler.end();
		
        return true;
    }

    static public function query(sql:String) : ResultSet
    {
		try
		{
			if (profiler != null) profiler.begin('SQL query');
			if (Type.enumIndex(logLevel) >= 2) trace("SQL QUERY: " + sql);
			var r = connection.query(sql);
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
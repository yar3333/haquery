#if (php || neko)

package haquery.server.db;

import haquery.server.db.HaqDbDriver;
import haquery.server.db.HaqDbDriver_mysql;
import haquery.server.HaqProfiler;
import haquery.server.Lib;

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

    static public function connect(connectionString:String) : Bool
    {
		if (connection != null) return true;
		
		var re = new EReg('^([a-z]+)\\://([_a-zA-Z0-9]+)\\:(.+?)@([_.a-zA-Z0-9]+)(?:[:](\\d+))?/([_a-zA-Z0-9]+)$', '');
		if (!re.match(connectionString))
		{
			Lib.assert(false, "Connection string invalid format.");
		}
		
        Lib.profiler.begin("openDatabase");
            connection = Type.createInstance(
                 Type.resolveClass('haquery.server.db.HaqDbDriver_' + re.matched(1))
				,[ re.matched(4), re.matched(2), re.matched(3), re.matched(6), re.matched(5) != "" ? Std.parseInt(re.matched(5)) : 0 ]
            );
        Lib.profiler.end();
		
        return true;
    }

    static public function query(sql:String) : ResultSet
    {
        Lib.profiler.begin('SQL query');
        var r = connection.query(sql);
        Lib.profiler.end();
        return r;
    }

    static public function affectedRows() : Int
    {
        return connection.affectedRows();
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
package haquery.server.db;

import php.db.Mysql;
import haquery.server.db.HaqDbDriver;
import haquery.server.db.HaqDbDriver_mysql;
import haquery.server.HaqProfiler;
import haquery.server.HaQuery;
import php.db.ResultSet;

class HaqDb
{
    static public var connection : HaqDbDriver = null;

    static public function connect(params : { type:String, host:String, user:String, pass:String, database:String }) : Bool
    {
		if (connection != null) return true;
        
        HaQuery.profiler.begin("openDatabase");
            connection = Type.createInstance(
                Type.resolveClass(
                    'haquery.server.db.HaqDbDriver_' + params.type), 
                    [ params.host, params.user, params.pass, params.database ]
                );
        HaQuery.profiler.end();
		
        return true;
    }

    static public function query(sql:String) : ResultSet
    {
        HaQuery.profiler.begin('SQL query');
        var r = connection.query(sql);
        HaQuery.profiler.end();
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



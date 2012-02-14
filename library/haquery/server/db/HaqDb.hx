package haquery.server.db;

import haquery.server.db.HaqDbDriver;
import haquery.server.db.HaqDbDriver_mysql;
import haquery.server.HaqProfiler;
import haquery.server.Lib;

#if php
import php.db.ResultSet;
#elseif neko
import neko.db.ResultSet;
#end

class HaqDb
{
    static public var connection : HaqDbDriver = null;

    static public function connect(params : { type:String, host:String, user:String, pass:String, database:String }) : Bool
    {
		if (connection != null) return true;
        
        Lib.profiler.begin("openDatabase");
            connection = Type.createInstance(
                Type.resolveClass(
                    'haquery.server.db.HaqDbDriver_' + params.type), 
                    [ params.host, params.user, params.pass, params.database ]
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



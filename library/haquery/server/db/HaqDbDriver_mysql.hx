package haquery.server.db;

import Type;
import haquery.server.db.HaqDbDriver;
import haquery.server.Lib;

#if php
import php.db.Connection;
import php.db.Mysql;
import php.db.ResultSet;
#elseif neko
import neko.db.Connection;
import neko.db.Mysql;
import neko.db.ResultSet;
#elseif cpp
import cpp.db.Connection;
import cpp.db.Mysql;
import cpp.db.ResultSet;
#end

class HaqDbDriver_mysql implements HaqDbDriver
{
	var database : String;
	var connection : Connection;
	
	public function new(host:String, user:String, pass:String, database:String, port:Int=0) : Void
    {
		this.database = database;
		connection = Mysql.connect( { host:host, user:user, pass:pass, database:database, port:port != 0 ? port : 3306, socket:null } );
		connection.request('set names utf8');
        connection.request("set character_set_client='utf8'");
        connection.request("set character_set_results='utf8'");
        connection.request("set collation_connection='utf8_general_ci'");
    }

    public function query(sql:String) : ResultSet
    {
        if (Lib.config.sqlTraceLevel >= 2) trace("SQL QUERY: " + sql);
        
		#if php
		var r = connection.request(sql);
		var errno = untyped __call__('mysql_errno');
		#else
		var r = null;
		var errno = 0;
		try { r = connection.request(sql); }
		catch (e:Dynamic) { errno = 1; }
		#end
		
        if (errno != 0)
        {
            throw "sql query error:\n"
				+ "SQL QUERY: " + sql + "\n"
				+ "SQL RESULT: " + affectedRows() + " rows affected, error code = " + errno + " (" + getLastErrorMessage() + ").";
        }
        if (Lib.config.sqlTraceLevel>0)
        {
            if (Lib.config.sqlTraceLevel == 1 && errno != 0) trace("SQL QUERY: " + sql);
            if (Lib.config.sqlTraceLevel >= 3 || errno != 0)
			{
                trace("SQL RESULT: " + affectedRows() + " rows affected, error code = " + errno + " (" + getLastErrorMessage() + ').');
			}
        }
        return r;
    }

    public function affectedRows() : Int
    {
		#if php
		return untyped __call__('mysql_affected_rows');
		#else
		return -1;
		#end
    }
	
	private function getLastErrorMessage() : String
	{
		#if php
		return untyped __call__('mysql_error');
		#else
		return "";
		#end
	}

    public function getTables() : Array<String>
    {
        var r : Array<String> = [];
        var rows = query('SHOW TABLES FROM `' + database + '`');
        for (row in rows)
        {
			var fields = Reflect.fields(row);
			r.push(Reflect.field(row, fields[0]));
		}
        return r;
    }

	
	public function getFields(table:String) : Array<HaqDbTableFieldData>
    {
        var r = new Array<HaqDbTableFieldData>();
        var rows = query("SHOW COLUMNS FROM `" + table + "`");
        for (row in rows)
        {
			var fields = Reflect.fields(row);
			r.push({
                 name : row.Field
                ,type : Reflect.field(row, 'Type')
                ,isNull : Reflect.field(row, 'Null') == 'YES'
                ,isKey : row.Key == 'PRI'
                ,isAutoInc : row.Extra == 'auto_increment'
			});
        }
        return r;
    }

    public function quote(v:Dynamic) : String
    {
		switch (Type.typeof(v))
        {
            case ValueType.TClass(cls):
                if (cls == String)
                {
                    return connection.quote(v);
                }
                else
                if (cls == Date)
                {
                    var date : Date = cast(v, Date);
                    return "'" + date.toString() + "'";
                }
            
            case ValueType.TInt:
                return Std.string(v);
            
            case ValueType.TFloat:
                return Std.string(v);
            
            case ValueType.TNull:
                return 'NULL';
            
            case ValueType.TBool:
                return cast(v, Bool) ? '1' : '0';
            
            default:
        }
        
        throw "Unsupported parameter type '" + Type.getClassName(Type.getClass(v)) + "'.";
    }

    public function lastInsertId() : Int
    {
        return connection.lastInsertId();
    }
	
	public function getForeignKeys(table:String) : Array<HaqDbTableForeignKey>
    {
        var sql = "
  SELECT
   u.table_schema AS 'schema',
   u.table_name AS 'table',
   u.column_name AS 'key',
   u.referenced_table_schema AS 'parentSchema',
   u.referenced_table_name AS 'parentTable',
   u.referenced_column_name AS 'parentKey'
  FROM information_schema.table_constraints AS c
  INNER JOIN information_schema.key_column_usage AS u
  USING( constraint_schema, constraint_name )
  WHERE c.constraint_type = 'FOREIGN KEY'
    AND c.table_schema = '" + database + "'
    AND u.table_name = '" + table + "'
  ORDER BY u.table_schema, u.table_name, u.column_name;
";
		var rows : ResultSet = query(sql);
		var r = new Array<HaqDbTableForeignKey>();
		for (row in rows)
		{
			r.push(row);
		}
		return r;
    }
	
	public function getUniques(table:String) : Hash<Array<String>>
	{
		var rows : ResultSet = query("SHOW INDEX FROM `" + table + "` WHERE Non_unique=0 AND Key_name<>'PRIMARY'");
		var r = new Hash<Array<String>>();
		for (row in rows)
		{
			var key = row.Key_name;
            if (!r.exists(key))
            {
                r.set(key, new Array<String>());
            }
            r.get(key).push(row.Column_name);
		}
		return r;
	}

}

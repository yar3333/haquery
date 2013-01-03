package haquery.server.db;

import sys.db.Connection;
import sys.db.Mysql;
import sys.db.ResultSet;
import haquery.Exception;
import haquery.server.db.HaqDbDriver;

class HaqDbDriver_mysql implements HaqDbDriver
{
	static inline var renewTimeoutSeconds = 120;
	
	var host : String;
	var user : String;
	var pass : String;
	var database : String;
	var port : Int;
	
	var connection : Connection;
	
	var lastAccessTime = 0.0;
	
	public function new(host:String, user:String, pass:String, database:String, port:Int=0) : Void
    {
		this.host = host;
		this.user = user;
		this.pass = pass;
		this.database = database;
		this.port = port;
		
		renew();
    }
	
	function renew()
	{
		if (Date.now().getTime() - lastAccessTime > renewTimeoutSeconds * 1000)
		{
			if (connection != null)
			{
				try
				{
					connection.request("SELECT 0");
				}
				catch (_:Dynamic)
				{
					close();
				}
			}
			
			if (connection == null)
			{
				connection = Mysql.connect( { host:host, user:user, pass:pass, database:database, port:port != 0 ? port : 3306, socket:null } );
				connection.request("set names utf8");
				connection.request("set character_set_client='utf8'");
				connection.request("set character_set_results='utf8'");
				connection.request("set collation_connection='utf8_general_ci'");
			}
		}
		
		lastAccessTime = Date.now().getTime();
	}

    public function query(sql:String) : ResultSet
    {
		renew();
		
		#if php
		var r = connection.request(sql);
		var errno = untyped __call__("mysql_errno");
		if (errno != 0)
		{
			throw new HaqDbException(errno, untyped __call__("mysql_error"));
		}
		return r;
		#else
		var r = null;
		var errno = 0;
		var errormsg = "";
		try { r = connection.request(sql); }
		catch (e:Dynamic)
		{
			throw new HaqDbException(1, Std.string(e));
		}
		return r;
		#end
    }
	
	public function close() : Void
	{
		try { connection.close(); } catch (_:Dynamic) { }
		connection = null;
	}
	
    public function getTables() : Array<String>
    {
        var r : Array<String> = [];
        var rows = query("SHOW TABLES FROM `" + database + "`");
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
                ,type : Reflect.field(row, "Type")
                ,isNull : Reflect.field(row, "Null") == "YES"
                ,isKey : row.Key == "PRI"
                ,isAutoInc : row.Extra == "auto_increment"
			});
        }
        return r;
    }

    public function quote(v:Dynamic) : String
    {
		switch (Type.typeof(v))
        {
            case ValueType.TClass(cls):
                if (Std.is(v, String))
                {
					return connection.quote(v);
                }
                else
                if (Std.is(v, Date))
                {
                    var date : Date = cast(v, Date);
                    return "'" + date.toString() + "'";
                }
            
            case ValueType.TInt:
                return Std.string(v);
            
            case ValueType.TFloat:
                return Std.string(v);
            
            case ValueType.TNull:
                return "NULL";
            
            case ValueType.TBool:
                return cast(v, Bool) ? "1" : "0";
            
            default:
        }
        
        throw new Exception("Unsupported parameter type '" + Type.getClassName(Type.getClass(v)) + "'.");
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

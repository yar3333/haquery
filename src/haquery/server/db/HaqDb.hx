package haquery.server.db;

import php.Lib;
import php.db.Mysql;
import haquery.server.HaQuery;
import haquery.server.db.HaqDbDriver;
import haquery.server.db.HaqDbDriver_mysql;
import haquery.server.HaqProfiler;
import php.db.ResultSet;


/**
 * Обеспечивает работу с БД.
 * Использует для этого объекты, реализующие интерфейс HaqDbDriverInterface.
 */
class HaqDb
{
    static public var connection : HaqDbDriver = null;

    static public function connect(dbType:String=null, dbServer:String=null, dbUsername:String=null, dbPassword:String=null, dbDatabase:String=null) : Bool
    {
		if (connection != null) return true;
        
        if (dbType == null)
        {
            dbType = HaQuery.config.dbType;
            dbServer = HaQuery.config.dbServer;
            dbUsername = HaQuery.config.dbUsername;
            dbPassword = HaQuery.config.dbPassword;
            dbDatabase = HaQuery.config.dbDatabase;
        }
        if (dbType!=null && dbServer!=null && dbDatabase!=null)
        {
            connection = Type.createInstance(Type.resolveClass('haquery.server.db.HaqDbDriver_' + dbType), [dbServer, dbUsername, dbPassword, dbDatabase]);
            return true;
        }

        return false;
    }

    /**
     * Выполняет запрос к БД.
     */
    static public function query(sql:String) : ResultSet
    {
        if (HaQuery.config.isTraceProfiler) HaqProfiler.begin('SQL query');
        var r = connection.query(sql);
        if (HaQuery.config.isTraceProfiler) HaqProfiler.end();
        return r;
    }

    /**
     * Возвращает кол-во обработанных записей БД.
     * @return int Кол-во записей.
     */
    static public function affectedRows() : Int
    {
        return connection.affectedRows();
    }

    /**
     * Возвращает строку, безопасную для подстановки в SQL-запрос.
     */
    static public function quote(v:Dynamic) : String
    {
        return connection.quote(v);
    }

    /**
     * Возвращает последнее использованное значение автоинкремента.
     * Эту ф-ию полезно вызывать после выполнения INSERT, чтобы определить id вставленного элемента.
     */
    static public function lastInsertId() : Int
    {
        return connection.lastInsertId();
    }

}



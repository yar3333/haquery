package haquery.server.db;

import php.db.Connection;
import php.db.ResultSet;

typedef HaqDbTableFieldData = {
	var name : String;
	var type : String;
	var isNull : Bool;
	var isKey : Bool;
	var isAutoInc : Bool;
}

typedef HaqDbTableForeignKey = {
   var schema : String;
   var table : String;
   var key : String;
   var parentSchema : String;
   var parentTable : String;
   var parentKey : String;
}

interface HaqDbDriver 
{
    public var connection(default, null) : Connection;
    
	function query(sql:String) : ResultSet;
    function quote(s:Dynamic) : String;
    function lastInsertId() : Int;
    function affectedRows() : Int;
    
	function getTables() : Array<String>;
    function getFields(table:String) : Array<HaqDbTableFieldData>;
	function getForeignKeys(table:String) : Array<HaqDbTableForeignKey>;
	function getUniqueFields(table:String) : Array<String>;
}
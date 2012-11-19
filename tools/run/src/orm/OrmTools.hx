package orm;

import haquery.server.db.HaqDbDriver;
using haquery.StringTools;

class OrmTools 
{
	public static function capitalize(s:String) : String
	{
		return s.length == 0 ? s : s.substr(0, 1).toUpperCase() + s.substr(1);
	}
	
	static function sqlTypeCheck(checked:String, type:String) : Bool
	{
		var re = new EReg('^' + type + '(\\(|$)', '');
		return re.match(checked);
	}
	
	public static function sqlType2haxeType(sqlType:String) : String
	{
		sqlType = sqlType.toUpperCase();
		if (sqlType == 'TINYINT(1)')           return 'Bool';
		if (sqlTypeCheck(sqlType, 'TINYINT'))  return 'Int';
		if (sqlTypeCheck(sqlType, 'SMALLINT')) return 'Int';
		if (sqlTypeCheck(sqlType, 'SHORT'))    return 'Int';
		if (sqlTypeCheck(sqlType, 'LONG'))     return 'Int';
		if (sqlTypeCheck(sqlType, 'INT'))      return 'Int';
		if (sqlTypeCheck(sqlType, 'INT24'))    return 'Int';
		if (sqlTypeCheck(sqlType, 'BIGINT'))   return 'Float';
		if (sqlTypeCheck(sqlType, 'LONGLONG')) return 'Float';
		if (sqlTypeCheck(sqlType, 'DECIMAL'))  return 'Float';
		if (sqlTypeCheck(sqlType, 'FLOAT'))    return 'Float';
		if (sqlTypeCheck(sqlType, 'DOUBLE'))   return 'Float';
		if (sqlTypeCheck(sqlType, 'DATE'))     return 'Date';
		if (sqlTypeCheck(sqlType, 'DATETIME')) return 'Date';
		return 'String';
	}
	
	public static function createVar(haxeName:String, haxeType:String, haxeDefVal:String = null) : OrmHaxeVar
	{
		return {
			 haxeName : haxeName
			,haxeType : haxeType
			,haxeDefVal : haxeDefVal
			,name : null
			,type : null
			,isNull : false
			,isKey : false
			,isAutoInc : false
		};
	}
	
	static function field2var(f:HaqDbTableFieldData) : OrmHaxeVar
	{ 
		return {
			 haxeName : f.name
			,haxeType : sqlType2haxeType(f.type)
			,haxeDefVal : (f.name == 'position' ? 'null' : null)
			
			,name : f.name
			,type : f.type
			,isNull : f.isNull
			,isKey : f.isKey
			,isAutoInc : f.isAutoInc
		};
	}
	
	public static function fields2vars(fields:Iterable<HaqDbTableFieldData>) : List<OrmHaxeVar>
	{
		return Lambda.map(fields, OrmTools.field2var);
	}
}
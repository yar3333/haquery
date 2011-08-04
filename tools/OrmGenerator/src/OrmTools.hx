package ;

import OrmHaxeClassGenerator;
import haquery.server.db.HaqDbDriver;

class OrmTools 
{
	public static function capitalize(s:String) : String
	{
		return s.length == 0 ? s : s.substr(0, 1).toUpperCase() + s.substr(1);
	}
	
	public static function indent(text:String, ind = "\t") : String
    {
        if (text == '') return '';
		return ind + text.replace("\n", "\n" + ind);
    }
	
	public static function splitFullClassName(fullClassName:String) : { packageName:String, className:String }
	{
		var packageName = '';
		var className = fullClassName;
		
		if (fullClassName.lastIndexOf('.') != -1)
		{
			packageName = fullClassName.substr(0, fullClassName.lastIndexOf('.'));
			className = fullClassName.substr(fullClassName.lastIndexOf('.') + 1);
		}
		
		return { packageName:packageName, className:className };
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
		if (sqlTypeCheck(sqlType, 'SHORT'))    return 'Int';
		if (sqlTypeCheck(sqlType, 'LONG'))     return 'Int';
		if (sqlTypeCheck(sqlType, 'INT'))      return 'Int';
		if (sqlTypeCheck(sqlType, 'INT24'))    return 'Int';
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
			 name : null
			,type : null
			,isNull : false
			,isKey : false
			,isAutoInc : false
			
			,haxeName : haxeName
			,haxeType : haxeType
			,haxeDefVal : haxeDefVal
		};
	}
	
	static function field2var(f:HaqDbTableFieldData) : OrmHaxeVar
	{ 
		return {
			 name : f.name
			,type : f.type
			,isNull : f.isNull
			,isKey : f.isKey
			,isAutoInc : f.isAutoInc
			
			,haxeName : f.name
			,haxeType : sqlType2haxeType(f.type)
			,haxeDefVal : (f.name == 'position' ? 'null':null)
		};
	}
	
	public static function fields2vars(fields:Iterable<HaqDbTableFieldData>) : List<OrmHaxeVar>
	{
		return Lambda.map(fields, OrmTools.field2var);
	}
}
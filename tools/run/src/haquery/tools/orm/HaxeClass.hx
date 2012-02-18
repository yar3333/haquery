package haquery.tools.orm;

typedef HaxeVar = {>haquery.tools.HaxeClass.HaxeVar,
	var name : String;
	var type : String;
	var isNull : Bool;
	var isKey : Bool;
	var isAutoInc : Bool;
}

typedef HaxeClass = haquery.tools.HaxeClass;

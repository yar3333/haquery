package haquery.common;

class HaqDumper 
{
	public static function getDump(v:Dynamic, limit=3, level=0) : String
	{
		if (level >= limit) return "...";
		
		var prefix = ""; for (i in 0...level) prefix += "\t";
		
		var s : String;
		switch (Type.typeof(v))
		{
			case ValueType.TBool:
				s = "BOOL" + (v ? "true" : "false") + ")";
			
			case ValueType.TNull:
				s = "NULL";
				
			case ValueType.TClass(c):
				if (c == String)
				{
					s = "STRING(" + Std.string(v) + ")";
				}
				else
				if (c == Array)
				{
					s = "ARRAY(" + v.length + ")\n";
					for (item in cast(v, Array<Dynamic>))
					{
						s += getDump(item, limit, level + 1);
					}
				}
				else
				if (c == Hash)
				{
					s = "HASH\n";
					for (key in cast(v, Hash<Dynamic>).keys())
					{
						s += prefix + key + " => " + getDump(v.get(key), limit, level + 1);
					}
				}
				else
				{
					s = "CLASS(" + Type.getClassName(c) + ")\n" + getObjectDump(v, limit, level + 1);
				}
			
			case ValueType.TEnum(e):
				s = "ENUM(" + Type.getEnumName(e) + ") = " + Type.enumConstructor(v);
			
			case ValueType.TFloat:
				s = "FLOAT(" + Std.string(v) + ")";
			
			case ValueType.TInt:
				s = "INT(" + Std.string(v) + ")";
			
			case ValueType.TObject:
				s = "OBJECT" + "\n" + getObjectDump(v, limit, level + 1);
			
			case ValueType.TFunction, ValueType.TUnknown:
				s = "FUNCTION OR UNKNOW";
		};
		return s != "" ? s + "\n" : "";
	}
	
	static function getObjectDump(obj:Dynamic, limit, level:Int) : String
	{
		var prefix = ""; for (i in 0...level) prefix += "\t";
		var s = "";
		for (fieldName in Reflect.fields(obj))
		{
			s += prefix + fieldName + " : " + getDump(Reflect.field(obj, fieldName), limit, level);
		}
		return s;
	}	
}
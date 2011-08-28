package haquery.server;

import Type;

class HaqTools 
{
	static function serverVarToClientString(v:Dynamic) : String
	{
		if (untyped __physeq__(v, null)) return 'null';
		if (untyped __physeq__(v, true)) return 'true';
		if (untyped __physeq__(v, false)) return 'false';
		if (Type.typeof(v) == ValueType.TInt) return Std.string(v);
		
		if (Type.typeof(v) == ValueType.TObject)
		{
			if (Type.getClassName(Type.getClass(v)) == 'String')
			{
				return 'StringTools.unescape("' + StringTools.escape(v) + '")';
			}
			if (Type.getClassName(Type.getClass(v)) == 'Date')
			{
				var date : Date = cast(v, Date);
				return "new Date(" + date.getTime() + ")";
			}
		}
		
		throw "Can't convert this type from server to client (typeof = " + Type.typeof(v) + ").";
	}
	
	static public function getCallClientFunctionString(func:String, params:Array<Dynamic>) : String
	{
		return func 
			+ "(" 
				+ Lambda.map(params, function(p) { return serverVarToClientString(p); } ).join(', ') 
			+ ")";
	}
}
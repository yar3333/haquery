package haquery.server;

import stdlib.Std;

class HaqParams
{
	public var map(default, null) : Map<String, String>;
	
	public function new(map:Map<String, String>)
	{
		this.map = map;
	}
	
	public inline function exists(name:String) : Bool
	{
		return map.exists(name);
	}
	
	public function get(name:String, ?defVal:String) : String
	{
		var r = map.get(name);
		return r != null ? r : defVal;
	}
	
	public inline function getInt(name:String, ?defVal:Int) : Int
	{
		return Std.parseInt(map.get(name), defVal);
	}
	
	public inline function getFloat(name:String, ?defVal:Float) : Float
	{
		return Std.parseFloat(map.get(name), defVal);
	}
	
	public inline function getBool(name:String) : Bool
	{
		return Std.bool(map.get(name));
	}
}
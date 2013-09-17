package haquery.common;

import haquery.base.HaqComponent;
using stdlib.StringTools;

private typedef Var =
{
	var d : String; // send direction: s - to server, c - to client, b - both
	var v : Dynamic;
}

@:keep class HaqStorage
{
    var staticVars : Map<String,Var>;
    var instanceVars : Map<String,Var>;
	
	public static inline var DESTINATION_BOTH = "b";
	public static inline var DESTINATION_SERVER = "s";
	public static inline var DESTINATION_CLIENT = "c";
	
	public function new()
	{
		staticVars = new Map<String,Var>();
		instanceVars = new Map<String,Var>();
	}
	
	function getFullTag(clas:Class<HaqComponent>) : String
	{
		var name = Type.getClassName(clas);
		if (name.startsWith("components.") || name.startsWith("pages."))
		{
			return name.substr(0, name.lastIndexOf("."));
		}
		else
		{
			throw "HaqStorage may be used for classes in 'components' and 'pages' packages only.";
			return null;
		}
	}
	
	public function setStaticVar(clas:Class<HaqComponent>, key:String, value:Dynamic, destination=#if server DESTINATION_CLIENT #else DESTINATION_SERVER #end)
	{
		staticVars.set(getFullTag(clas) + ":" + key , { d: destination, v: value });
	}
	
	public function getStaticVar(clas:Class<HaqComponent>, key:String) : Dynamic
	{
		return staticVars.get(getFullTag(clas) + ":" + key).v;
	}
	
	public function existsStaticVar(clas:Class<HaqComponent>, key:String) : Bool
	{
		return staticVars.exists(getFullTag(clas) + ":" + key);
	}
	
	public function removeStaticVar(clas:Class<HaqComponent>, key:String) : Void
	{
		staticVars.remove(getFullTag(clas) + ":" + key);
	}
	
	public function setInstanceVar(fullID:String, key:String, value:Dynamic, destination=#if server DESTINATION_CLIENT #else DESTINATION_SERVER #end)
	{
		instanceVars.set(fullID + ":" + key, { d: destination, v: value });
	}
	
	public function getInstanceVar(fullID:String, key:String) : Dynamic
	{
		return instanceVars.get(fullID + ":" + key).v;
	}
	
	public function existsInstanceVar(fullID:String, key:String) : Bool
	{
		return instanceVars.exists(fullID + ":" + key);
	}
	
	public function removeInstanceVar(fullID:String, key:String) : Void
	{
		instanceVars.remove(fullID + ":" + key);
	}
	
	public function getStorageToSend() : HaqStorage
	{
		var r = new HaqStorage();
		
		for (k in staticVars.keys())
		{
			var v = staticVars.get(k);
			if (v.d != #if server DESTINATION_SERVER #else DESTINATION_CLIENT #end)
			{
				r.staticVars.set(k, v);
			}
		}
		
		for (k in instanceVars.keys())
		{
			var v = instanceVars.get(k);
			if (v.d != #if server DESTINATION_SERVER #else DESTINATION_CLIENT #end)
			{
				r.instanceVars.set(k, v);
			}
		}
		
		return r;
	}
}

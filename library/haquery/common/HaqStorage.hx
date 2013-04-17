package haquery.common;

import haquery.base.HaqComponent;
using stdlib.StringTools;

typedef Var =
{
	var d : String; // send direction: s - to server, c - to client, b - both
	var v : Dynamic;
}

@:keep class HaqStorage
{
    var staticVars : Hash<Var>;
    var instanceVars : Hash<Var>;
	
	public function new()
	{
		staticVars = new Hash<Var>();
		instanceVars = new Hash<Var>();
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
	
	public function setStaticVar(clas:Class<HaqComponent>, key:String, value:Dynamic, dontSendBack=false)
	{
		staticVars.set(
			  getFullTag(clas) + ":" + key
			, {
				  d: dontSendBack ? #if server "c" #else "s" #end : "b"
				, v: value
			  }
		);
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
	
	public function setInstanceVar(component:HaqComponent, key:String, value:Dynamic, dontSendBack=false)
	{
		instanceVars.set(
			  component.fullID + ":" + key
			, {
				  d: dontSendBack ? #if server "c" #else "s" #end : "b"
				, v: value
			  }
		);
	}
	
	public function getInstanceVar(component:HaqComponent, key:String) : Dynamic
	{
		return instanceVars.get(component.fullID + ":" + key).v;
	}
	
	public function existsInstanceVar(component:HaqComponent, key:String) : Bool
	{
		return instanceVars.exists(component.fullID + ":" + key);
	}
	
	public function removeInstanceVar(component:HaqComponent, key:String) : Void
	{
		instanceVars.remove(component.fullID + ":" + key);
	}
	
	public function getStorageToSend() : HaqStorage
	{
		var r = new HaqStorage();
		
		for (k in staticVars.keys())
		{
			var v = staticVars.get(k);
			if (v.d != #if server "s" #else "c" #end)
			{
				r.staticVars.set(k, v);
			}
		}
		
		for (k in instanceVars.keys())
		{
			var v = instanceVars.get(k);
			if (v.d != #if server "s" #else "c" #end)
			{
				r.instanceVars.set(k, v);
			}
		}
		
		return r;
	}
}

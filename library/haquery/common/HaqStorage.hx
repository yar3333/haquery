package haquery.common;

import haquery.base.HaqComponent;
using stdlib.StringTools;

@:keep class HaqStorage
{
    var staticVars : Hash<Dynamic>;
    var instanceVars : Hash<Dynamic>;
	
	public function new()
	{
		staticVars = new Hash<Dynamic>();
		instanceVars = new Hash<Dynamic>();
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
	
	public function setStaticVar(clas:Class<HaqComponent>, key:String, value:Dynamic)
	{
		staticVars.set(getFullTag(clas)+ ":" + key, value);
	}
	
	public function getStaticVar(clas:Class<HaqComponent>, key:String) : Dynamic
	{
		return staticVars.get(getFullTag(clas) + ":" + key);
	}
	
	public function existsStaticVar(clas:Class<HaqComponent>, key:String) : Bool
	{
		return staticVars.exists(getFullTag(clas) + ":" + key);
	}
	
	public function removeStaticVar(clas:Class<HaqComponent>, key:String) : Void
	{
		staticVars.remove(getFullTag(clas) + ":" + key);
	}
	
	public function setInstanceVar(component:HaqComponent, key:String, value:Dynamic)
	{
		instanceVars.set(component.fullID + ":" + key, value);
	}
	
	public function getInstanceVar(component:HaqComponent, key:String) : Dynamic
	{
		return instanceVars.get(component.fullID + ":" + key);
	}
	
	public function existsInstanceVar(component:HaqComponent, key:String) : Bool
	{
		return instanceVars.exists(component.fullID + ":" + key);
	}
	
	public function removeInstanceVar(component:HaqComponent, key:String) : Void
	{
		instanceVars.remove(component.fullID + ":" + key);
	}
}

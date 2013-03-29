package haquery.common;

import haquery.base.HaqComponent;
using stdlib.StringTools;

@:keep class HaqSharedStorage
{
    var data : Hash<Hash<Dynamic>>;
	
	public function new()
	{
		data = new Hash<Hash<Dynamic>>();
	}
	
	function set(group:String, key:String, value:Dynamic)
	{
		if (!data.exists(group))
		{
			data.set(group, new Hash<Dynamic>());
		}
		data.get(group).set(key, value);
	}
	
	function get(group:String, key:String) : Dynamic
	{
		if (data.exists(group))
		{
			return data.get(group).get(key);
		}
		return null;
	}
	
	function getClassName(clas:Class<HaqComponent>)
	{
		var name = Type.getClassName(clas);
		if (name.startsWith("components.") || name.startsWith("pages."))
		{
			return name.substr(0, name.lastIndexOf("."));
		}
		else
		{
			throw "HaqSharedStorage may be used for classes in 'components' and 'pages' packages only.";
			return null;
		}
	}
	
	public function setStaticVar(clas:Class<HaqComponent>, key:String, value:Dynamic)
	{
		set(getClassName(clas), key, value);
	}
	
	public function getStaticVar(clas:Class<HaqComponent>, key:String) : Dynamic
	{
		return get(getClassName(clas), key);
	}
	
	public function setInstanceVar(component:HaqComponent, key:String, value:Dynamic)
	{
		set(component.fullID, key, value);
	}
	
	public function getInstanceVar(component:HaqComponent, key:String) : Dynamic
	{
		return get(component.fullID, key);
	}
}

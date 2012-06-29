package haquery.common;

import haquery.base.HaqComponent;

class HaqSharedStorage
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
		if (name != "haquery.server.HaqComponent" && name != "haquery.server.HaqComponent")
		{
			return name.substr(0, name.lastIndexOf("."));
		}
		return "haquery.HaqComponent";
	}
	
	public function setComponentTemplateVar(clas:Class<HaqComponent>, key:String, value:Dynamic)
	{
		set(getClassName(clas), key, value);
	}
	
	public function getComponentTemplateVar(clas:Class<HaqComponent>, key:String) : Dynamic
	{
		return get(getClassName(clas), key);
	}
	
	public function setComponentInstanceVar(component:HaqComponent, key:String, value:Dynamic)
	{
		set(component.fullID, key, value);
	}
	
	public function getComponentInstanceVar(component:HaqComponent, key:String) : Dynamic
	{
		return get(component.fullID, key);
	}
}

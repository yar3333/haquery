// This is autogenerated file. Do not edit!

package components.haquery.context;

class TemplateServer
{
	var component : haquery.server.HaqComponent;
	
	public var dataID(dataID_getter, null) : haquery.server.HaqQuery;
	inline function dataID_getter() : haquery.server.HaqQuery
	{
		return component.q('#dataID');
	}
	
	public var p(p_getter, null) : haquery.server.HaqQuery;
	inline function p_getter() : haquery.server.HaqQuery
	{
		return component.q('#p');
	}

	public function new(component:haquery.server.HaqComponent) : Void
	{
		this.component = component;
	}
}
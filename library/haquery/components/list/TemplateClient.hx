// This is autogenerated file. Do not edit!

package haquery.components.list;

class TemplateClient
{
	var component : haquery.client.HaqComponent;
	
	public var length(length_getter, null) : haquery.client.HaqQuery;
	inline function length_getter() : haquery.client.HaqQuery
	{
		return component.q('#length');
	}

	public function new(component:haquery.client.HaqComponent) : Void
	{
		this.component = component;
	}
}

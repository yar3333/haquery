// This is autogenerated file. Do not edit!

package haquery.components.tabs;

class TemplateClient
{
	var component : haquery.client.HaqComponent;
	
	public var tabs(tabs_getter, null) : haquery.client.HaqQuery;
	inline function tabs_getter() : haquery.client.HaqQuery
	{
		return component.q('#tabs');
	}

	public function new(component:haquery.client.HaqComponent) : Void
	{
		this.component = component;
	}
}

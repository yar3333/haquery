// This is autogenerated file. Do not edit!

#if (php || neko)

package haquery.components.tabs;

class TemplateServer
{
	var component : haquery.server.HaqComponent;
	
	public var tabs(tabs_getter, null) : haquery.server.HaqQuery;
	inline function tabs_getter() : haquery.server.HaqQuery
	{
		return component.q('#tabs');
	}

	public function new(component:haquery.server.HaqComponent) : Void
	{
		this.component = component;
	}
}

#end
// This is autogenerated file. Do not edit!

package components.haquery.waiter;

class TemplateServer
{
	var component : haquery.server.HaqComponent;
	
	public var shadow(shadow_getter, null) : haquery.server.HaqQuery;
	inline function shadow_getter() : haquery.server.HaqQuery
	{
		return component.q('#shadow');
	}
	
	public var animation(animation_getter, null) : haquery.server.HaqQuery;
	inline function animation_getter() : haquery.server.HaqQuery
	{
		return component.q('#animation');
	}
	
	public var text(text_getter, null) : haquery.server.HaqQuery;
	inline function text_getter() : haquery.server.HaqQuery
	{
		return component.q('#text');
	}

	public function new(component:haquery.server.HaqComponent) : Void
	{
		this.component = component;
	}
}
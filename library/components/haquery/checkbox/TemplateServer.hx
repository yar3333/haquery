// This is autogenerated file. Do not edit!

package components.haquery.checkbox;

class TemplateServer
{
	var component : haquery.server.HaqComponent;
	
	public var cb(cb_getter, null) : haquery.server.HaqQuery;
	inline function cb_getter() : haquery.server.HaqQuery
	{
		return component.q('#cb');
	}
	
	public var text(text_getter, null) : components.haquery.literal.Server;
	inline function text_getter() : components.haquery.literal.Server
	{
		return cast component.components.get('text');
	}

	public function new(component:haquery.server.HaqComponent) : Void
	{
		this.component = component;
	}
}
// This is autogenerated file. Do not edit!

#if (php || neko)

package haquery.components.button;

class TemplateServer
{
	var component : haquery.server.HaqComponent;
	
	public var b(b_getter, null) : haquery.server.HaqQuery;
	inline function b_getter() : haquery.server.HaqQuery
	{
		return component.q('#b');
	}

	public function new(component:haquery.server.HaqComponent) : Void
	{
		this.component = component;
	}
}

#end
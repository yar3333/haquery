// This is autogenerated file. Do not edit!

#if (php || neko)

package haquery.components.urlmenu;

class TemplateServer
{
	var component : haquery.server.HaqComponent;
	
	public var m(m_getter, null) : haquery.server.HaqQuery;
	inline function m_getter() : haquery.server.HaqQuery
	{
		return component.q('#m');
	}

	public function new(component:haquery.server.HaqComponent) : Void
	{
		this.component = component;
	}
}

#end
// This is autogenerated file. Do not edit!

package components.button;

class Template extends haquery.components.button.Template
{
	var component : #if php haquery.server.HaqComponent #else haquery.client.HaqComponent #end;
	
	public var b(b_getter, null) : #if php haquery.server.HaqQuery #else haquery.client.HaqQuery #end;
	inline function b_getter() : #if php haquery.server.HaqQuery #else haquery.client.HaqQuery #end
	{
		return component.q('#b');
	}

	public function new(component:#if php haquery.server.HaqComponent #else haquery.client.HaqComponent #end) : Void
	{
		this.component = component;
	}
}
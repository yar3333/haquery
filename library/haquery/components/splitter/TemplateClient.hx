// This is autogenerated file. Do not edit!

#if js

package haquery.components.splitter;

class TemplateClient
{
	var component : haquery.client.HaqComponent;
	
	public var a(a_getter, null) : haquery.client.HaqQuery;
	inline function a_getter() : haquery.client.HaqQuery
	{
		return component.q('#a');
	}
	
	public var b(b_getter, null) : haquery.client.HaqQuery;
	inline function b_getter() : haquery.client.HaqQuery
	{
		return component.q('#b');
	}
	
	public var f(f_getter, null) : haquery.client.HaqQuery;
	inline function f_getter() : haquery.client.HaqQuery
	{
		return component.q('#f');
	}
	
	public var s(s_getter, null) : haquery.client.HaqQuery;
	inline function s_getter() : haquery.client.HaqQuery
	{
		return component.q('#s');
	}

	public function new(component:haquery.client.HaqComponent) : Void
	{
		this.component = component;
	}
}

#end
// This is autogenerated file. Do not edit!

package pages.index;

class TemplateClient
{
	var component : haquery.client.HaqComponent;
	
	public var pagebt(pagebt_getter, null) : components.haquery.button.Client;
	inline function pagebt_getter() : components.haquery.button.Client
	{
		return cast component.components.get('pagebt');
	}
	
	public var pagesbt(pagesbt_getter, null) : haquery.client.HaqQuery;
	inline function pagesbt_getter() : haquery.client.HaqQuery
	{
		return component.q('#pagesbt');
	}
	
	public var users(users_getter, null) : components.haquery.list.Client;
	inline function users_getter() : components.haquery.list.Client
	{
		return cast component.components.get('users');
	}
	
	public var status(status_getter, null) : haquery.client.HaqQuery;
	inline function status_getter() : haquery.client.HaqQuery
	{
		return component.q('#status');
	}

	public function new(component:haquery.client.HaqComponent) : Void
	{
		this.component = component;
	}
}

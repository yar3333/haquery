package haquery.client;

import js.Lib;
import jQuery.JQuery;
import haquery.server.HaqEvent;
import haquery.server.HaQuery;

class HaqComponent extends haquery.base.HaqComponent
{
	public function new() : Void
	{
		super();
	}
	
	public function construct(manager:HaqComponentManager, parent:HaqComponent, tag:String,  id:String) : Void
	{
		super.commonConstruct(manager, parent, tag, id);
		
		createEvents();
		createChildComponents();
		if (Reflect.hasMethod(this, 'init')) Reflect.callMethod(this, Reflect.field(this, 'init'), []);
	}
	
	public function createChildComponents() : Void
	{
		var childComponentsData = manager.getChildComponents(this);
		for (component in childComponentsData)
		{
			manager.createComponent(this, component.tag, component.id);
		}
	}
	
	public function q(?selector:String, ?base:Dynamic) : JQuery
	{
		if (selector != null && Type.getClassName(Type.getClass(selector)) == "String" && this.prefixID != '')
		{
			selector = StringTools.replace(selector, '#', '#' + this.prefixID);
		}
		return new JQuery(selector, base);
	}
}

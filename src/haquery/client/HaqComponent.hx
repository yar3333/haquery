package haquery.client;

import js.Lib;
import jQuery.JQuery;
import haquery.server.HaqEvent;
import haquery.server.HaQuery;

class HaqComponent extends haquery.base.HaqComponent<HaqComponent>
{
    var manager : HaqComponentManager;
	
	var serverHandlers(default,null) : Hash<Array<String>>;
    
	public function construct(manager:HaqComponentManager, parent:HaqComponent, tag:String,  id:String, serverHandlers:Hash<Array<String>>) : Void
	{
		super.commonConstruct(parent, tag, id);
		
		this.manager = manager;
        this.serverHandlers = serverHandlers;
        
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

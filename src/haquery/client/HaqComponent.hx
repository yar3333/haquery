package haquery.client;

import js.Lib;
import haquery.client.HaqQuery;

class HaqComponent extends haquery.base.HaqComponent
{
    var manager : HaqComponentManager;
	
	var serverHandlers(default,null) : Hash<Array<String>>;
    
	public function construct(manager:HaqComponentManager, parent:HaqComponent, tag:String,  id:String, serverHandlers:Hash<Array<String>>) : Void
	{
		super.commonConstruct(parent, tag, id);
		
		this.manager = manager;
        this.serverHandlers = serverHandlers;
        
		connectElemEventHandlers();
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
	
	public function q(?selector:String, ?base:Dynamic) : HaqQuery
	{
		if (selector != null && Type.getClassName(Type.getClass(selector)) == "String" && this.prefixID != '')
		{
			selector = StringTools.replace(selector, '#', '#' + this.prefixID);
		}
		return new HaqQuery(selector, base);
	}
    
    private function connectElemEventHandlers() : Void
    {
        HaqElemEventManager.connect(this, this, manager.templates);
    }
}

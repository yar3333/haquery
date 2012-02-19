#if js

package haquery.client;

import haquery.client.Lib;
import haquery.client.HaqQuery;

class HaqComponent extends haquery.base.HaqComponent
{
    var manager : HaqTemplateManager;
	
	public function construct(manager:HaqTemplateManager, fullTag:String, parent:HaqComponent, id:String, factoryInitParams:Array<Dynamic>=null) : Void
	{
		super.commonConstruct(fullTag, parent, id);
		
		this.manager = manager;
        
		connectElemEventHandlers();
        createEvents();
		createChildComponents();
		
		if (factoryInitParams != null)
		{
			if (Reflect.isFunction(Reflect.field(this, 'factoryInit')))
			{
				Reflect.callMethod(this, Reflect.field(this, 'factoryInit'), factoryInitParams);
			}
			else
			{
				throw "Client class of the " + fullTag + " component must contain method factoryInit() to be instanceable on the client via factory component.";
			}
		}
		
		if (Reflect.isFunction(Reflect.field(this, 'init')))
        {
            Reflect.callMethod(this, Reflect.field(this, 'init'), []);
        }
	}
	
	public function createChildComponents() : Void
	{
		var childComponentsData = manager.getChildComponents(this);
		for (component in childComponentsData)
		{
			manager.createComponent(this, component.tag, component.id);
		}
	}
	
	public function q(selector:String, ?base:Dynamic) : HaqQuery
	{
		if (selector != null && prefixID != '')
		{
			selector = StringTools.replace(selector, '#', '#' + prefixID);
		}
		return new HaqQuery(selector, base);
	}
    
    private function connectElemEventHandlers() : Void
    {
		HaqElemEventManager.connect(this, this, manager);
    }
	
	/**
	 * Call server method, marked as @shared.
	 */
	function callSharedMethod(method:String, ?params:Array<Dynamic>, ?callbackFunc:Dynamic->Void) : Void
	{
		HaqElemEventManager.callServerMethod(fullID, method, params, callbackFunc);
	}
}

#end
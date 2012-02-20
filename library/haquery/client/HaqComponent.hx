#if js

package haquery.client;

import haquery.client.Lib;
//import haquery.client.HaqQuery;
import js.JQuery;

using haquery.StringTools;

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
		for (component in manager.getChildComponents(this))
		{
			manager.createComponent(this, component.fullTag, component.id);
		}
	}
	
	public function q(selector:String, ?base:Dynamic) : HaqQuery
	{
		var prefixCssClass = fullTag.replace(".", "_") + HaqDefines.DELIMITER;
		
		if (selector != null && prefixID != '')
		{
			selector = StringTools.replace(selector, '#', '#' + prefixID);
		}
		
		var jq = new JQuery(selector, base);
		
		untyped __js__("
jq.haqueryPrefixCssClass = prefixCssClass;

jq.globalizeClassName = function(className)
{
	return className.replace(/~/, this.haqueryPrefixCssClass);
};

var oldAddClass = jq.addClass;
jq.addClass = function(name)
{
	return oldAddClass.call(this, this.globalizeClassName(name));
}

var oldRemoveClass = jq.removeClass;
jq.removeClass = function(name)
{
	return oldRemoveClass.call(this, this.globalizeClassName(name));
}

var oldHasClass = jq.hasClass;
jq.hasClass = function(name)
{
	return oldHasClass.call(this, this.globalizeClassName(name));
}
		");
		
		return jq;
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
package haquery.client;

import haquery.client.Lib;
import haquery.client.HaqCssGlobalizer;
import haquery.client.HaqQuery;
import js.JQuery;

using haquery.StringTools;

class HaqComponent extends haquery.base.HaqComponent
{
	public function construct(manager:HaqTemplateManager, fullTag:String, parent:HaqComponent, id:String, factoryInitParams:Array<Dynamic>=null) : Void
	{
		super.commonConstruct(manager, fullTag, parent, id);
		
		connectElemEventHandlers();
        createEvents();
		createChildComponents();
		
		if (factoryInitParams == null)
		{
			if (Reflect.isFunction(Reflect.field(this, 'init')))
			{
				Reflect.callMethod(this, Reflect.field(this, 'init'), []);
			}
		}
		else
		{
			if (Reflect.isFunction(Reflect.field(this, 'factoryInit')))
			{
				Reflect.callMethod(this, Reflect.field(this, 'factoryInit'), factoryInitParams);
			}
		}
	}
	
	public function createChildComponents() : Void
	{
		for (component in manager.getChildComponents(this))
		{
			manager.createComponent(this, component.fullTag, component.id);
		}
	}
	
	public function q(?arg:Dynamic, ?base:Dynamic) : HaqQuery
	{
		var cssGlobalizer = new HaqCssGlobalizer(fullTag);
		
		if (arg != null && arg != "" && Type.getClass(arg) == String)
		{
			var selector : String = arg;
			if (selector != null && prefixID != '')
			{
				selector = selector.replace('#', '#' + prefixID);
			}
			arg = cssGlobalizer.selector(selector);
		}
		
		var jq = new HaqQuery(arg, base);
		
		untyped 
		{
			jq.haqueryAddClass = jq.addClass;
			jq.addClass = function(name)
			{
				return jq.haqueryAddClass(cssGlobalizer.className(name));
			};
			
			jq.haqueryRemoveClass = jq.removeClass;
			jq.removeClass = function(name)
			{
				return jq.haqueryRemoveClass(cssGlobalizer.className(name));
			};

			jq.haqueryHasClass = jq.hasClass;
			jq.hasClass = function(name)
			{
				return jq.haqueryHasClass(cssGlobalizer.className(name));
			};
		}
		
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

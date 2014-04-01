package haquery.base;

#if !macro

import haquery.common.HaqDefines;
import haquery.common.HaqEvent;
import haquery.common.HaqComponentTools;
import haquery.common.Generated;
import stdlib.Exception;
using stdlib.StringTools;

#if server
import haquery.server.HaqTemplateManager;
private typedef Component = haquery.server.HaqComponent;
private typedef BasePage = haquery.server.BasePage;
#else
import haquery.client.HaqTemplateManager;
private typedef Component = haquery.client.HaqComponent;
private typedef BasePage = haquery.client.BasePage;
#end

#end

@:keepSub
@:allow(haquery.common)
@:allow(haquery.server)
@:allow(haquery.client)
class HaqComponent
{
#if !macro
	
	public var page(default,null) : BasePage;
	
	public var parent(default,null) : Component;

    /**
     * Component package name (for example: 'components.haquery.button').
     */
    public var fullTag(default, null)  : String;
    
    /**
     * Empty for page.
     */
    public var id(default,null) : String;

    /**
     * Empty for page.
     */
    public var fullID(default,null) : String;

    /**
     * Prefix for DOM elements ID.
     */
    public var prefixID(default,null) : String;
	
    /**
     * Children components.
     */
    public var components(default, null) : HaqComponents<Component>;
	
	#if !fullCompletion @:noCompletion #end
    var nextAnonimID : Int;
	
	function new() : Void
	{
		components = new Map<String,Component>();
		nextAnonimID = 0;
	}
	
	#if !fullCompletion @:noCompletion #end
	function commonConstruct(fullTag:String, parent:Component, id:String) 
	{
		if (id == null || id == '') id = parent != null ? parent.getNextAnonimID() : '';
		
		this.fullTag = fullTag;
		this.parent = parent;
		this.id = id;
		
		this.fullID = (parent!=null ? parent.prefixID : '') + id;
		this.prefixID = this.fullID != '' ? this.fullID + HaqDefines.DELIMITER : '';
		
		if (parent != null) 
		{
			if (parent.components.exists(id))
			{
				throw new Exception("Component with same id = '" + id + "' already exist.");
			}
			parent.components.set(id, cast this);
		}
	}
	
	#if !fullCompletion @:noCompletion #end
	static var eventNamesCache = new Map<String, Array<String>>();
	
	#if !fullCompletion @:noCompletion #end
	function createEvents() : Void
	{
		if (parent == null) return;
		
		var eventNames = eventNamesCache.get(fullTag);
		if (eventNames == null)
		{
			eventNames = [];
			for (field in Type.getInstanceFields(Type.getClass(this)))
			{
				if (field.startsWith('event_'))
				{
					eventNames.push(field.substr("event_".length));
				}
			}
			eventNamesCache.set(fullTag, eventNames);
		}
		
		for (eventName in eventNames)
		{
			var field = "event_" + eventName;
			var event : HaqEvent<Dynamic> = Reflect.field(this, field);
			if (event == null)
			{
				event = new HaqEvent(cast this, eventName);
				Reflect.setField(this, field, event);
			}
			parent.connectEventHandlers(event);
		}
	}
	
	#if !fullCompletion @:noCompletion #end
	function connectEventHandlers(event:HaqEvent<Dynamic>) : Void
	{
        var handlerName = event.component.id + '_' + event.name;
        if (Reflect.isFunction(Reflect.field(this, handlerName)))
        {
            event.bind(cast this, handlerName);
        }
	}
	
	#if !fullCompletion @:noCompletion #end
	function callMethod(f:String)
	{
		if (Reflect.isFunction(Reflect.field(this, f)))
		{
			#if server
			if (page.config.logSystemCalls) trace("HAQUERY " + f + " [" + fullID + "/" + fullTag + "]");
			var start = 0.0; if (page.config.logSlowSystemCalls >= 0) start = Sys.time();
			
			haquery.server.Lib.profiler.begin(f, fullTag);
			#end
			
			Reflect.callMethod(this, Reflect.field(this, f), []);
			
			#if server
			haquery.server.Lib.profiler.end();
			
			if (page.config.logSlowSystemCalls >= 0 && Sys.time() - start >= page.config.logSlowSystemCalls)
			{
				trace("HAQUERY SLOW: " + Std.string(Std.int((Sys.time() - start) * 1000)).lpad(" ", 5) + " " + f + " [" + fullID + "/" + fullTag + "]");
			}
			#end
		}
	}

	
	#if !fullCompletion @:noCompletion #end
    public function forEachComponent(f:String, isFromTopToBottom=true) : Void
    {
		#if server
		if (page.statusCode == 302 || page.statusCode == 301) return; 
		#end
		
		if (isFromTopToBottom) callMethod(f);
        for (component in components) component.forEachComponent(f, isFromTopToBottom);
        if (!isFromTopToBottom) callMethod(f);
    }
	
    /**
     * Find child by relative ID.
     * @param fullID Relative ID (for example: "header-menu-items").
     */
	#if !fullCompletion @:noCompletion #end
    function findComponent(fullID:String) : Component
    {
        if (fullID == null) return null;
		if (fullID == '') return cast this;
        var ids = fullID.split(HaqDefines.DELIMITER);
        var r = this;
        for (id in ids)
        {
            r = cast r.components.get(id);
			if (r == null) return null;
        }
		return cast r;
    }
	
	#if !fullCompletion @:noCompletion #end
	function getNextAnonimID() : String
	{
		nextAnonimID++;
		return "haqc_" + Std.string(nextAnonimID);
	}
	
	#if !fullCompletion @:noCompletion #end
	function callElemEventHandler(elemID:String, eventName:String) : Dynamic
    {
		var handler = elemID + '_' + eventName;
		
		try
		{
			return Reflect.callMethod(this, Reflect.field(this, handler), [ this, null ]);
		}
		catch (e:String)
		{
			if (e == "Invalid call")
			{
				throw new Exception("Invalid call: " + Type.getClassName(Type.getClass(this)) + "." + handler + "(t, e).");
			}
			Exception.rethrow(e);
			return null;
		}
    }
#end
}

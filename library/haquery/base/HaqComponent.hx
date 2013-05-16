package haquery.base;

#if !macro

import haquery.common.HaqDefines;
import haquery.common.HaqEvent;
import haquery.common.HaqComponentTools;
import stdlib.Exception;
using stdlib.StringTools;

#if server
import haquery.server.HaqTemplateManager;
private typedef Component = haquery.server.HaqComponent;
private typedef Page = models.server.Page;
#else
import haquery.client.HaqTemplateManager;
private typedef Component = haquery.client.HaqComponent;
private typedef Page = models.client.Page;
#end

#end

@:keepSub class HaqComponent
{
#if !macro
	
	public var page(default,null) : Page;
	
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
	
    var nextAnonimID : Int;
	
	public function new() : Void
	{
		components = new Hash<Component>();
		nextAnonimID = 0;
		
		var templateClass = HaqComponentTools.getTemplateClass(Type.getClass(this));
		if (templateClass != null)
		{
			Reflect.setField(this, "_template", Type.createInstance(templateClass, [ this ]));
		}
	}
	
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
	
	function createEvents() : Void
	{
		if (parent != null)
		{
			for (field in Type.getInstanceFields(Type.getClass(this)))
			{
				if (field.startsWith('event_'))
				{
					var event : HaqEvent<Dynamic> = Reflect.field(this, field);
					if (event == null)
					{
						event = new HaqEvent(cast this, field.substr("event_".length));
						Reflect.setField(this, field, event);
					}
					parent.connectEventHandlers(event);
				}
			}
		}
	}
	
	public function connectEventHandlers(event:HaqEvent<Dynamic>) : Void
	{
        var handlerName = event.component.id + '_' + event.name;
        if (Reflect.isFunction(Reflect.field(this, handlerName)))
        {
            event.bind(cast this, handlerName);
        }
	}
	
    public function forEachComponent(f:String, isFromTopToBottom=true) : Void
    {
		#if server
		if (page.statusCode == 302 || page.statusCode == 301) return; 
		#end
		
		if (isFromTopToBottom && Reflect.isFunction(Reflect.field(this, f)))
        {
			Reflect.callMethod(this, Reflect.field(this, f), []);
        }
        
        for (component in components) component.forEachComponent(f, isFromTopToBottom);
        
        if (!isFromTopToBottom && Reflect.isFunction(Reflect.field(this, f)))
        {
            Reflect.callMethod(this, Reflect.field(this, f), []);
        }
    }
	
    /**
     * Find child by relative ID.
     * @param fullID Relative ID (for example: "header-menu-items").
     */
    public function findComponent(fullID:String) : Component
    {
        if (fullID == null) return null;
		if (fullID == '') return cast this;
        var ids = fullID.split(HaqDefines.DELIMITER);
        var r = this;
        for (id in ids)
        {
            if (!r.components.exists(id))
			{
				return null;
			}
            r = cast r.components.get(id);
        }
		return cast r;
    }
	
	public function getNextAnonimID() : String
	{
		nextAnonimID++;
		return "haqc_" + Std.string(nextAnonimID);
	}
	
	public function callElemEventHandler(elemID:String, eventName:String) : Dynamic
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
				throw new Exception("Invalid call: " + Type.getClassName(Type.getClass(this)) + "." + handler + "(t, e).", e);
			}
			Exception.rethrow(e);
			return null;
		}
    }
#end
}

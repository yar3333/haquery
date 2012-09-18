package haquery.base;

import haquery.common.HaqDefines;
import haquery.common.HaqEvent;

#if !client
import haquery.server.Lib;
import haquery.server.HaqPage;
import haquery.server.HaqTemplateManager;
private typedef Component = haquery.server.HaqComponent;
#else
import haquery.client.Lib;
import haquery.client.HaqPage;
import haquery.client.HaqTemplateManager;
private typedef Component = haquery.client.HaqComponent;
#end

using haquery.StringTools;

class HaqComponent extends haquery.macros.HaqComponent
{
    public var manager(default,null) : HaqTemplateManager;
	public var parent(default,null) : Component;
	public var page(default,null) : HaqPage;

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
	
	function new() : Void
	{
		components = new Hash<Component>();
		nextAnonimID = 0;
		
		var templateClass = haquery.base.HaqComponentTools.getTemplateClass(Type.getClass(this));
		if (templateClass != null)
		{
			Reflect.setField(this, "_template", Type.createInstance(templateClass, [ this ]));
		}
	}
	
	function commonConstruct(manager:HaqTemplateManager, fullTag:String, parent:Component, id:String) 
	{
		if (id == null || id == '') id = parent != null ? parent.getNextAnonimID() : '';
		
		this.manager = manager;
		this.fullTag = fullTag;
		this.parent = parent;
		this.page = parent != null ? parent.page : cast(this, HaqPage);
		this.id = id;
		
		this.fullID = (parent!=null ? parent.prefixID : '') + id;
		this.prefixID = this.fullID != '' ? this.fullID + HaqDefines.DELIMITER : '';
		
		if (parent != null) 
		{
			Lib.assert(!parent.components.exists(id), "Component with same id '" + id + "' already exist.");
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
		if (isFromTopToBottom && Reflect.isFunction(Reflect.field(this, f)))
        {
            #if !client
			if (Lib.config.isTraceComponent)
			{
				trace("HAQUERY [" + fullID + "] " + fullTag + "." + f + "...");
			}
			#end
			Reflect.callMethod(this, Reflect.field(this, f), []);
        }
        
        for (component in components) component.forEachComponent(f, isFromTopToBottom);
        
        if (!isFromTopToBottom && Reflect.isFunction(Reflect.field(this, f)))
        {
            #if !client
			if (Lib.config.isTraceComponent)
			{
				trace("HAQUERY [" + fullID + "] " + fullTag + "." + f + "...");
			}
			#end
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
}
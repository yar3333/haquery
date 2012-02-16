package haquery.base;

#if (php || neko)
import haquery.server.HaqEvent;
import haquery.server.Lib;
import haquery.server.HaqTemplate;
private typedef Component = haquery.server.HaqComponent;
#elseif js
import haquery.client.HaqEvent;
import haquery.client.Lib;
import haquery.client.HaqTemplate;
private typedef Component = haquery.client.HaqComponent;
#end

using haquery.StringTools;

class HaqComponent
{
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
    public var components(default, null) : Hash<Component>;
	
    var nextAnonimID : Int;
	
	function new() : Void
	{
		components = new Hash<Component>();
		nextAnonimID = 0;
		
		switch (Type.typeof(this))
		{
			case ValueType.TClass(cls):
				if (Lambda.has(Type.getInstanceFields(cls), "template"))
				{
					var className : String = Type.getClassName(cls);
					var lastPointPos = className.lastIndexOf(".");
					if (lastPointPos > 0)
					{
						var templateClassName = className.substr(0, lastPointPos) + ".Template";
						var templateClass = Type.resolveClass(templateClassName);
						if (templateClass != null)
						{
							Reflect.setField(this, "template", Type.createInstance(templateClass, [this]));
						}
					}
				}
			default:
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
					var event : HaqEvent = Reflect.field(this, field);
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
	
	public function connectEventHandlers(event:HaqEvent) : Void
	{
		//trace("base[" + fullID + "] connectEventHandlers event = " + event.name);
        var handlerName = event.component.id + '_' + event.name;
        if (Reflect.isFunction(Reflect.field(this, handlerName)))
        {
            event.bind(cast this, Reflect.field(this, handlerName));
        }
	}
	
    public function forEachComponent(f:String, isFromTopToBottom=true) : Void
    {
		if (isFromTopToBottom && Reflect.isFunction(Reflect.field(this, f)))
        {
            Reflect.callMethod(this, Reflect.field(this, f), []);
        }
        
        for (component in this.components) component.forEachComponent(f, isFromTopToBottom);
        
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
}
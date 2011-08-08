package haquery.base;

#if php
import haquery.server.HaqInternals;
import haquery.server.HaqComponentManager;
import haquery.server.HaqEvent;
import haquery.server.HaQuery;
typedef Component = haquery.server.HaqComponent;
#else
import haquery.client.HaqInternals;
import haquery.client.HaqComponentManager;
import haquery.client.HaqEvent;
import haquery.client.HaQuery;
typedef Component = haquery.client.HaqComponent;
#end

class HaqComponent
{
    var manager : HaqComponentManager;
	
    /**
     * ID компонента; для главной страницы равен пустой строке.
     */
    public var id(default,null) : String;

    /**
     * Родительский компонент.
     */
    public var parent(default,null) : Component;

    /**
     * Тег (название) компонента.
     */
    public var tag(default,null)  : String;

    /**
     * Полный ID компонента. Для главной страницы равен пустой строке.
     */
    public var fullID(default,null) : String;

    /**
     * Префикс ID для DOM-элементов компонента и его подкомпонентов (например: "parentID-compID-").
     */
    public var prefixID(default,null) : String;
	
    /**
     * Экземпляры дочерних компонентов.
     */
    public var components(default, null) : Hash<Component>;
	
    /**
     * ID для следующего анонимного дочернего компонента.
     */
    var nextAnonimID : Int;
	
	function new() : Void
	{
		components = new Hash<Component>();
		nextAnonimID = 0;
	}
	
	function commonConstruct(manager:HaqComponentManager, parent:Component, tag:String,  id:String) 
	{
		if (id == null || id == '') id = parent != null ? parent.getNextAnonimID() : '';
		
		this.manager = manager;
		this.parent = parent;
		this.tag = tag;
		this.id = id;
		
		this.fullID = (parent!=null ? parent.prefixID : '') + id;
		this.prefixID = this.fullID != '' ? this.fullID + HaqInternals.DELIMITER : '';
		
		if (parent != null) 
		{
			HaQuery.assert(!parent.components.exists(id), "Component with same id '" + id + "' already exist.");
			parent.components.set(id, cast(this, Component));
		}
	}
	
	function createEvents() : Void
	{
		if (parent!=null)
		{
			for (field in Type.getInstanceFields(Type.getClass(this)))
			{
				if (field.startsWith('event_'))
				{
					var event : HaqEvent = Reflect.field(this, field);
					if (event == null)
					{
						event = new HaqEvent(cast(this, Component), field.substr("event_".length));
						Reflect.setField(this, field, event);
					}
					parent.connectEventHandlers(cast(this, Component), event);
				}
			}
		}
	}
	
	public function connectEventHandlers(child:Component, event:HaqEvent) : Void
	{
		var handlerName = child.id + '_' + event.name;
		/*var hasMethod = false;
		try { hasMethod = Reflect.hasMethod(this, handlerName); } catch (e:Dynamic) {}*/
		//if (hasMethod)
		if (Reflect.hasMethod(this, handlerName))
		{
			event.bind(cast(this, Component), Reflect.field(this, handlerName));
		}
	}
	
    public function forEachComponent(f:String, isFromTopToBottom=true) : Void
    {
		if (isFromTopToBottom && Reflect.hasMethod(this, f)) Reflect.callMethod(this, Reflect.field(this, f), []);
        for (component in this.components) component.forEachComponent(f, isFromTopToBottom);
        if (!isFromTopToBottom && Reflect.hasMethod(this, f)) Reflect.callMethod(this, Reflect.field(this, f), []);
    }
	
    /**
     * Ишет компонент по его составному идентификатору относительно данного компонента.
     * @param string fullID Составной идентификатор компонента (например: "myID1-myID2-myID3").
     */
    public function findComponent(fullID) : Component
    {
        if (fullID == '') return cast(this, Component);
        var ids = fullID.split(HaqInternals.DELIMITER);
        var r = this;
        for (id in ids)
        {
            if (!r.components.exists(id))
			{
				return null;
			}
            r = r.components.get(id);
        }
		return cast(r, Component);
    }
	
	public function getNextAnonimID() : String
	{
		nextAnonimID++;
		return "haqc_" + Std.string(nextAnonimID);
	}
}
package components.haquery.factoryitem;

#if !client
import haquery.common.HaqEvent;
#else
import haquery.common.HaqEvent;
#end

class Base extends #if !client BaseServer #else BaseClient #end
{
	override function connectEventHandlers(event:HaqEvent<Dynamic>) : Void
	{
        if (parent != null && parent.parent != null)
        {
            var handlerName = event.component.id + '_' + event.name;
            if (Reflect.isFunction(Reflect.field(parent.parent, handlerName)))
            {
                event.bind(parent.parent, handlerName);
            }
        }
	}
}
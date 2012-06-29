package components.haquery.factoryitem;

#if !client
import haquery.server.HaqComponent;
import haquery.common.HaqEvent;
#else
import haquery.client.HaqComponent;
import haquery.common.HaqEvent;
#end

class Base extends HaqComponent
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
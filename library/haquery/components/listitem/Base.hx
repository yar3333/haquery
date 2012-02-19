package haquery.components.listitem;

#if php
import haquery.server.HaqComponent;
import haquery.server.HaqEvent;
#else
import haquery.client.HaqComponent;
import haquery.client.HaqEvent;
#end

class Base extends HaqComponent
{
	override function connectEventHandlers(event:HaqEvent) : Void
	{
        if (parent != null && parent.parent != null)
        {
            var handlerName = event.component.id + '_' + event.name;
            if (Reflect.isFunction(Reflect.field(parent.parent, handlerName)))
            {
                event.bind(parent.parent, Reflect.field(parent.parent, handlerName));
            }
        }
	}
}
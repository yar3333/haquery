package haquery.components.container;

#if php
import haquery.server.HaqComponent;
import haquery.server.HaqEvent;
#else
import haquery.client.HaqComponent;
import haquery.client.HaqEvent;
#end

class Base extends HaqComponent
{
	/*override function connectEventHandlers(event:HaqEvent) : Void
	{
        if (parent != null)
        {
            var handlerName = event.component.id + '_' + event.name;
            if (Reflect.isFunction(Reflect.field(parent, handlerName)))
            {
                event.bind(parent, Reflect.field(parent, handlerName));
            }
        }
	}*/
}
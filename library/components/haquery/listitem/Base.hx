package components.haquery.listitem;

import haquery.common.HaqEvent;

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
package haquery.components.listitem;

import haquery.client.HaqComponent;
import haquery.client.HaqEvent;

class Client extends HaqComponent
{
	override public function connectEventHandlers(child:HaqComponent, event:HaqEvent) : Void
	{
		var handlerName = /*parent.id + '_' +*/ child.id + '_' + event.name;
		if (Reflect.hasMethod(parent.parent, handlerName))
		{
			event.bind(parent.parent, Reflect.field(parent.parent, handlerName));
		}
	}
}

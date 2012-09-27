package components.haquery.list;

import haquery.server.Lib;
import haquery.common.HaqEvent;
import haquery.server.HaqComponent;

typedef ItemDataBoundEventArgs = {
	var item:HaqComponent;
	var obj:Dynamic;
}

class Server extends components.haquery.factory.Server
{
	public var event_itemDataBound : HaqEvent<ItemDataBoundEventArgs>;
	
	public function bind(objects:Iterable<Dynamic>)
    {
        Lib.assert(!page.isPostback, "List binding on postback is not allowed.");
		
        for (obj in objects)
        {
            var item = create(obj);
			event_itemDataBound.call({ item:item, obj:obj });
        }
    }
}

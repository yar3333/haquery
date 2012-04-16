package components.haquery.list;

import haquery.server.Lib;
import haquery.server.HaqEvent;

class Server extends components.haquery.factory.Server
{
	public var event_itemDataBound : HaqEvent;
	
	public function bind(objects:Iterable<Dynamic>)
    {
        Lib.assert(!Lib.isPostback, "List binding on postback is not allowed.");
		
        for (obj in objects)
        {
            var item = create(obj);
			event_itemDataBound.call([ item, obj ]);
        }
    }
}

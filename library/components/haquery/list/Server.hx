package components.haquery.list;

import haquery.server.Lib;
import haquery.server.HaqComponent;

class Server extends BaseServer
{
	public function bind<Data>(objects:Iterable<Data>, ?itemDataBound:HaqComponent->Data->Void)
    {
        Lib.assert(!page.isPostback, "List binding on postback is not allowed.");
		
        for (obj in objects)
        {
            var item = create(obj);
			if (itemDataBound != null)
			{
				itemDataBound(item, obj);
			}
        }
    }
}

package components.haquery.list;

import haquery.server.Lib;

class Server extends components.haquery.factory.Server
{
	public function bind(objects:Iterable<Dynamic>)
    {
        Lib.assert(!Lib.isPostback, "List binding on postback is not allowed.");
		
        for (obj in objects)
        {
            create(obj);
        }
    }
}

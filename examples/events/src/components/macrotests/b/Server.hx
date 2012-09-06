package components.macrotests.b;

import haquery.server.Lib;
import haquery.server.HaqComponent;

class Server extends components.macrotests.a.Server
{
    var event_checkB : haquery.common.HaqEvent<{ bbb:Int }>;
}
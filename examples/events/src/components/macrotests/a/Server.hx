package components.macrotests.a;

import haquery.server.Lib;
import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    var event_checkA : haquery.common.HaqEvent<{ aaa:Int }>;
}
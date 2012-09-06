package components.macrotests.b;

import haquery.client.Lib;
import haquery.client.HaqComponent;

class Client extends components.macrotests.a.Client
{
    var event_checkB : haquery.common.HaqEvent<{ bbb:Int }>;
}
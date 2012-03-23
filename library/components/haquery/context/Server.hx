package components.haquery.context;

import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    public var dataID(dataID_getter, null) : String;
    function dataID_getter() : String
    {
        return q('#dataID').val();
    }
}

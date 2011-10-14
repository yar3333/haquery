package haquery.components.contextpanel;

class Server extends haquery.components.container.Server
{
    public var dataID(dataID_getter, null) : String;
    function dataID_getter() : String
    {
        return q('#dataID').val();
    }
}

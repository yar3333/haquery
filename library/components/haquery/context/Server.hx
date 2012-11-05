package components.haquery.context;

class Server extends BaseServer
{
    public var dataID(getDataID, null) : String;
    
	function getDataID() : String
    {
        return q('#dataID').val();
    }
}

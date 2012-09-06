package components.haquery.context;

import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    public var dataID(getDataID, null) : String;
    
	function getDataID() : String
    {
        return q('#dataID').val();
    }
}

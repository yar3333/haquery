package components.haquery.list;

class Client extends BaseClient
{
	public var length(get_length, null) : Int;
    
    function get_length() : Int
    {
		return page.storage.existsInstanceVar(fullID, "length")
			? page.storage.getInstanceVar(fullID, "length")
			: 0;
    }
}
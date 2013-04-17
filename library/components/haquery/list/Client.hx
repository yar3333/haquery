package components.haquery.list;

class Client extends BaseClient
{
	public var length(get_length, null) : Int;
    
    function get_length() : Int
    {
		return page.storage.existsInstanceVar(this, "length")
			? page.storage.getInstanceVar(this, "length")
			: 0;
    }
}
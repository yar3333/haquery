package components.haquery.list;

class Client extends BaseClient
{
	public var length(get_length, null) : Int;
    
    function get_length() : Int
    {
        return Std.parseInt(q('#length').val());
    }
}
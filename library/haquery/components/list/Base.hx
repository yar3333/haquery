package haquery.components.list;

class Base extends #if (php || neko) haquery.server.HaqComponent #else haquery.client.HaqComponent #end
{
	public var length(length_getter, null) : Int;
    
    function length_getter() : Int
    {
        return Std.parseInt(q('#length').val());
    }
}
package components.haquery.factory;

class Base extends #if !client haquery.server.HaqComponent #else haquery.client.HaqComponent #end
{
	public var length(length_getter, null) : Int;
    
    function length_getter() : Int
    {
        return Std.parseInt(q('#length').val());
    }
}
package haquery.components.list;

class Base extends #if (php || neko) haquery.components.templater.Server #else haquery.components.templater.Client #end
{
	public var length(length_getter, null) : Int;
    
    function length_getter() : Int
    {
        return Std.parseInt(q('#length').val());
    }
}
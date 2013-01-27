package components.haquery.sfactory;

class Base extends #if !client BaseServer #else BaseClient #end
{
	public var length(length_getter, null) : Int;
    
    function length_getter() : Int
    {
        return Std.parseInt(q('#length').val());
    }
}
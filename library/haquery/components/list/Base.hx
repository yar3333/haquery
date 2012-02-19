package haquery.components.list;

#if php
import haquery.server.HaqComponent;
#else
import haquery.client.HaqComponent;
#end

class Base extends HaqComponent
{
	public var length(length_getter, null) : Int;
    
    function length_getter() : Int
    {
        return Std.parseInt(q('#length').val());
    }
}
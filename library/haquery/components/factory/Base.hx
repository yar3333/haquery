package haquery.components.factory;

#if php
import haquery.server.HaqComponent;
import haquery.server.HaqEvent;
#else
import haquery.client.HaqComponent;
import haquery.client.HaqEvent;
#end

class Base extends HaqComponent
{
	public var length(length_getter, length_setter) : Int;
    
    function length_getter() : Int
    {
        return Std.parseInt(q('#length').val());
    }	
    
    function length_setter(n:Int) : Int
    {
        q('#length').val(n);
        return n;
    }	
    
    override function connectEventHandlers(event:HaqEvent) : Void
	{
        if (parent != null)
        {
            var handlerName = id + '_' + event.name;
            if (Reflect.isFunction(Reflect.field(parent, handlerName)))
            {
                event.bind(parent, Reflect.field(parent, handlerName));
            }
        }
	}
}
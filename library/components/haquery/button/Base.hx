package components.haquery.button;

#if php
import haquery.server.HaqComponent;
#elseif js
import haquery.client.HaqComponent;
#end

class Base extends HaqComponent
{
    public var enabled(enabled_getter, enabled_setter) : Bool;
    
    function enabled_getter() : Bool
    {
        return !q('#c').hasClass('disabled');
    }
    
    function enabled_setter(enable : Bool) : Bool
    {
        if (enable) q('#c').removeClass('disabled');
        else        q('#c').addClass('disabled');
        return enable;
    }
}

package haquery.components.uploader;

#if php
import haquery.server.HaqComponent;
#else
import haquery.client.HaqComponent;
#end

class Base extends HaqComponent
{
    public var enabled(enabled_getter, enabled_setter) : Bool;
    
    function enabled_getter() : Bool
    {
        return !q('#form').hasClass('disabled');
    }
    
    function enabled_setter(enable : Bool) : Bool
    {
        if (enable) q('#form').removeClass('disabled');
        else        q('#form').addClass('disabled');
        return enable;
    }
}

package components.haquery.uploader;

#if php
typedef Container = components.haquery.container.Server;
#else
typedef Container = components.haquery.container.Client;
#end

class Base extends Container
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

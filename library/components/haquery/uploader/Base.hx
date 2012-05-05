package components.haquery.uploader;

#if !client
typedef Component = haquery.server.HaqComponent;
#else
typedef Component = haquery.client.HaqComponent;
#end

class Base extends Component
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

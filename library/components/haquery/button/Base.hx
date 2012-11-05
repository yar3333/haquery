package components.haquery.button;

class Base extends #if !client BaseServer #else BaseClient #end
{
    public var enabled(enabled_getter, enabled_setter) : Bool;
    
    function enabled_getter() : Bool
    {
        return !q('#b').hasClass('disabled');
    }
    
    function enabled_setter(enable : Bool) : Bool
    {
        if (enable) q('#b').removeClass('disabled');
        else        q('#b').addClass('disabled');
        return enable;
    }
}

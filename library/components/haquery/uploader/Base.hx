package components.haquery.uploader;

class Base extends #if !client BaseServer #else BaseClient #end
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

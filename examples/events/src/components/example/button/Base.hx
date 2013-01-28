package components.example.button;

class Base extends #if server BaseServer #else BaseClient #end
{
    public var enabled(get_enabled, set_enabled) : Bool;
    
    function get_enabled() : Bool
    {
        return !q("#container").hasClass('disabled');
    }
    
    function set_enabled(enable:Bool) : Bool
    {
        if (enable) q("#container").removeClass('disabled');
        else        q("#container").addClass('disabled');
        return enable;
    }
}

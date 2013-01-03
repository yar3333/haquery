package components.haquery.link;

class Base extends #if !client BaseServer #else BaseClient #end
{
    public var enabled(get_enabled, set_enabled) : Bool;
    
    function get_enabled() : Bool
    {
        return template().link.enabled;
    }
    
    function set_enabled(enable:Bool) : Bool
    {
        template().link.enabled = enable;
        return enable;
    }
}

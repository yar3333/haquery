package components.haquery.link;

class Base extends #if !client BaseServer #else BaseClient #end
{
    public var enabled(enabled_getter, enabled_setter) : Bool;
    
    #if !client
    var link : components.haquery.button.Server;
    #else
    var link : components.haquery.button.Client;
    #end
    
    function init()
    {
        link = cast components.get('link');
    }
    
    function enabled_getter() : Bool
    {
        return link.enabled;
    }
    
    function enabled_setter(enable : Bool) : Bool
    {
        link.enabled = enable;
        return enable;
    }
}

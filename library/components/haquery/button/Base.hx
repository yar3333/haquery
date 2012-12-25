package components.haquery.button;

#if server 
private typedef Template = TemplateServer;
#else
private typedef Template = TemplateClient;
#end

class Base extends #if !client BaseServer #else BaseClient #end
{
    public var enabled(get_enabled, set_enabled) : Bool;
    
    function get_enabled() : Bool
    {
        return !new Template(this).container.hasClass('disabled');
    }
    
    function set_enabled(enable:Bool) : Bool
    {
        if (enable) new Template(this).container.removeClass('disabled');
        else        new Template(this).container.addClass('disabled');
        return enable;
    }
}

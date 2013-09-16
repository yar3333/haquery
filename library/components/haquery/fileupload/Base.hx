package components.haquery.fileupload;

class Base extends #if server BaseServer #else BaseClient #end
{
    public var enabled(get_enabled, set_enabled) : Bool;
    
    function get_enabled() : Bool
    {
        return !q('#form').hasClass('disabled');
    }
    
    function set_enabled(enable : Bool) : Bool
    {
        if (enable) q('#form').removeClass('disabled');
        else        q('#form').addClass('disabled');
        return enable;
    }
}

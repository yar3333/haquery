package haquery.components.link;

#if php
import haquery.server.HaqComponent;
#else
import haquery.client.HaqComponent;
#end

class Base extends HaqComponent
{
    public var enabled(enabled_getter, enabled_setter) : Bool;
    
    #if php
    var link : haquery.components.button.Server;
    #else
    var link : haquery.components.button.Client;
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

    public function show()
    {
        link.show();
    }
    
    public function hide()
    {
        link.hide();
    }
}

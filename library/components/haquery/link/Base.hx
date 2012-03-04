package components.haquery.link;

#if php
import haquery.server.HaqComponent;
#elseif js
import haquery.client.HaqComponent;
#end

class Base extends HaqComponent
{
    public var enabled(enabled_getter, enabled_setter) : Bool;
    
    #if php
    var link : components.haquery.button.Server;
    #elseif js
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

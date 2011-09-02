package haquery.components.button;

import js.Lib;

import haquery.client.HaqComponent;
import haquery.client.HaqEvent;

class Client extends HaqComponent
{
    public var event_click : HaqEvent;
    
    public var enabled(enabled_getter, enabled_setter) : Bool;
    
    public function doClick()
    {
        q('#b').click();
    }

    public function b_click()
    {
        return enabled ? event_click.call() : false;
    }

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

    public function show()
    {
        q('#b').css('visibility','visible');
    }
}

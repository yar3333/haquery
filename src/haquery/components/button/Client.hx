package haquery.components.button;

import js.Lib;

import haquery.client.HaqComponent;
import haquery.client.HaqEvent;

class Client extends HaqComponent
{
    public var event_click : HaqEvent;
    
    public function doClick()
    {
        q('#b').click();
    }

    public function b_click()
    {
        return event_click.call([isActive()]);
    }

    public function setActive(isActive:Bool)
    {
        if (isActive) q('#b').addClass('active');
        else          q('#b').removeClass('active');
    }

    public function isActive()
    {
        return this.q('#b').hasClass('active');
    }

    public function show()
    {
        q('#b').css('visibility','visible');
    }
}

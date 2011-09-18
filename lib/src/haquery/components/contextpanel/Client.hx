package haquery.components.contextpanel;

import haquery.client.HaqQuery;

class Client extends haquery.components.container.Client
{
    var elem : HaqQuery;
    var timer : haxe.Timer;
    
    function show()
    {
        q('#p').show();
        var pos = elem.offset();
        q('#p').offset({
             left: Math.round(pos.left + elem.width() - q('#p').width())
            ,top:  Math.round(pos.top)
        });
    }

    public function attach(elem:HaqQuery)
    {
        var self = this;
        elem.mouseover(function() {
            self.elem = elem;
            self.show();
            self.p_mouseover();
        });
        elem.mouseout(function() {
            self.p_mouseout();
        });
    }

    function p_mouseover()
    {
        if (elem!=null) elem.addClass('contextpanel-active');
        if (timer!=null)
        {
            timer.stop();
            timer = null;
        }
    }

    function p_mouseout()
    {
        if (elem!=null) elem.removeClass('contextpanel-active');
        if (timer != null) timer.stop();
        var self = this;
        timer = haxe.Timer.delay(
            function() { 
                self.q('#p').hide(); 
                self.timer = null; 
            },
            1000
        );
    }
}
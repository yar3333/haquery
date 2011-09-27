package haquery.components.contextpanel;

import haquery.client.HaqQuery;

class Client extends haquery.components.container.Client
{
    var elem : HaqQuery;
    var timer : haxe.Timer;
    
    public var dataID(dataID_getter, null) : String;
    function dataID_getter() : String
    {
        return q('#dataID').val();
    }
    
    function show()
    {
        q('#p').show();
        var pos = elem.offset();
        q('#p').offset({
             left: Math.round(pos.left + elem.width() - q('#p').width())
            ,top:  Math.round(pos.top)
        });
    }

    public function attach(elem:HaqQuery, dataID:String)
    {
        var self = this;
        
        elem.mouseover(function()
        {
            self.elem = elem;
            self.q('#dataID').val(dataID);
            self.show();
            self.p_mouseover();
        });
        
        elem.mouseout(function()
        {
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
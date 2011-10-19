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
    
    var mouseOver : js.jQuery.JQuery.Event->Void;
    var mouseOut : js.jQuery.JQuery.Event->Void;
    
    public function new()
    {
        super();
        
        mouseOver = function(e:js.jQuery.JQuery.Event)
        {
            elem = new HaqQuery(e.currentTarget);
            var dataID = elem.data(prefixID + "dataID");
            trace("mouseOver " + dataID);
            q('#dataID').val(dataID);
            show();
            elem.addClass('contextpanel-active');
            if (timer!=null)
            {
                timer.stop();
                timer = null;
            }
        };
        
        mouseOut = function(e:js.jQuery.JQuery.Event)
        {
            if (elem != null)
            {
                elem.removeClass('contextpanel-active');
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
        };
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
        trace("attach " + dataID);
        
        elem.data(prefixID + "dataID", dataID);
        elem.mouseover(mouseOver);
        elem.mouseout(mouseOut);
    }
    
    public function detach(elem:HaqQuery)
    {
        elem.unbind("mouseover", mouseOver);
        elem.unbind("mouseout", mouseOut);
    }
}
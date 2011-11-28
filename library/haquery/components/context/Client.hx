package haquery.components.context;

import haquery.client.HaqQuery;
import haquery.client.HaqEvent;

class Client extends haquery.components.container.Client
{
    public var position : ContextPanelPosition;
    
    var event_show : HaqEvent;
    
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
        
        position = ContextPanelPosition.rightTopInner;
        
        mouseOver = function(e:js.jQuery.JQuery.Event) { elem = new HaqQuery(e.currentTarget);  innerMouseOver(); };
        mouseOut = function(e:js.jQuery.JQuery.Event) { innerMouseOut(); };
    }

    function innerMouseOver()
    {
        var dataID = elem.data(prefixID + "dataID");
        q('#dataID').val(dataID);
        show();
        elem.addClass('contextpanel-active');
        if (timer!=null)
        {
            timer.stop();
            timer = null;
        }
    }
    
    function innerMouseOut()
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
                500
            );
        }
    }
    
    function init()
    {
        if (q('#p').attr('position') != null)
        {
            position = Type.createEnumIndex(ContextPanelPosition, q('#p').attr('position'));
        }
    }
    
    function show()
    {
        q('#p').show();
        var pos = elem.offset();
        
        switch (position)
        {
            case ContextPanelPosition.rightTopInner:
                q('#p').offset({
                     left: Math.round(pos.left + elem.width() - q('#p').width())
                    ,top:  Math.round(pos.top)
                });
            case ContextPanelPosition.rightOuter:
                q('#p').offset({
                     left: Math.round(pos.left + elem.width())
                    ,top:  Math.round(pos.top)
                });
        }
        
        event_show.call([ q('#p'), elem ]);
    }
    
    public function attach(elem:HaqQuery, ?dataID:String)
    {
        elem.data(prefixID + "dataID", dataID);
        elem.mouseover(mouseOver);
        elem.mouseout(mouseOut);
    }
    
    public function detach(elem:HaqQuery)
    {
        elem.unbind("mouseover", mouseOver);
        elem.unbind("mouseout", mouseOut);
        innerMouseOut();
    }
    
    function p_mouseover(t, e:js.jQuery.JQuery.Event)
    {
        innerMouseOver();
    }
    
    function p_mouseout(t, e:js.jQuery.JQuery.Event)
    {
        innerMouseOut();
    }
}
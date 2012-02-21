package haquery.components.context;

import js.JQuery;
import haquery.client.HaqEvent;
import haquery.client.HaqComponent;

class Client extends HaqComponent
{
    public var position : ContextPanelPosition;
    
    var event_show : HaqEvent;
    
    var elem : JQuery;
    var timer : haxe.Timer;
    
    public var dataID(dataID_getter, null) : String;
    function dataID_getter() : String
    {
        return q('#dataID').val();
    }
    
    var mouseOver : js.JQuery.JqEvent->Void;
    var mouseOut : js.JQuery.JqEvent->Void;
    
    public function new()
    {
        super();
        
        position = ContextPanelPosition.rightTopInner;
        
        mouseOver = function(e:js.JQuery.JqEvent) { elem = new JQuery(e.currentTarget);  innerMouseOver(); };
        mouseOut = function(e:js.JQuery.JqEvent) { innerMouseOut(); };
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
            position = Type.createEnumIndex(ContextPanelPosition, Std.parseInt(q('#p').attr('position')));
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
    
    public function attach(elem:JQuery, ?dataID:String)
    {
        elem.data(prefixID + "dataID", dataID);
        elem.mouseover(mouseOver);
        elem.mouseout(mouseOut);
    }
    
    public function detach(elem:JQuery)
    {
        elem.unbind("mouseover", mouseOver);
        elem.unbind("mouseout", mouseOut);
        innerMouseOut();
    }
    
    function p_mouseover(t, e:js.JQuery.JqEvent)
    {
        innerMouseOver();
    }
    
    function p_mouseout(t, e:js.JQuery.JqEvent)
    {
        innerMouseOut();
    }
}
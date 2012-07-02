package components.haquery.context;

import js.JQuery;
import haquery.common.HaqEvent;
import haquery.client.HaqComponent;

typedef ShowEventArgs = {
	var elem : JQuery;
}

class Client extends HaqComponent
{
    var event_show : HaqEvent<ShowEventArgs>;
    
    var elem : JQuery;
    var timer : haxe.Timer;
    
    public var dataID(dataID_getter, null) : String;
    function dataID_getter() : String
    {
        return q('#dataID').val();
    }
    
    var mouseOver : JqEvent->Void;
    var mouseOut : JqEvent->Void;
    
    public function init()
    {
        mouseOver = function(e:JqEvent) { elem = new JQuery(e.currentTarget);  innerMouseOver(); };
        mouseOut = function(e:JqEvent) { innerMouseOut(); };
    }

    function innerMouseOver()
    {
        var dataID = elem.data(prefixID + "dataID");
        q('#dataID').val(dataID);
        show();
        if (timer != null)
        {
            timer.stop();
            timer = null;
        }
    }
    
    function innerMouseOut()
    {
        if (elem != null)
        {
            if (timer != null)
			{
				timer.stop();
			}
            timer = haxe.Timer.delay(function() { hide(); timer = null; }, 500);
        }
    }
    
    function show()
    {
		q('#container').show();
        q('#container').offset(getContextPosition(elem));
        event_show.call({ elem:elem });
    }
	
	function hide()
	{
		q('#container').hide();
	}
	
	/**
	 * Override if you want to display context panel in the different place.
	 * @param	elem
	 */
	function getContextPosition(elem:JQuery) : { left:Int, top:Int }
	{
		var pos = elem.offset();
		return {
			 left: Math.round(pos.left + elem.width() - q('#container').width())
			,top:  Math.round(pos.top)
		};
	}
    
    public function attach(elem:JQuery, ?dataID:String)
    {
        elem.data(prefixID + "dataID", dataID);
        elem.mouseover(mouseOver);
        elem.mouseout(mouseOut);
    }
    
    public function detach(elem:JQuery)
    {
        elem.unbind("mouseout", mouseOut);
        elem.unbind("mouseover", mouseOver);
        innerMouseOut();
    }
    
    function p_mouseover(t, e)
    {
        innerMouseOver();
    }
    
    function p_mouseout(t, e)
    {
        innerMouseOut();
    }
}
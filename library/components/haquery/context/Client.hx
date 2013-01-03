package components.haquery.context;

import js.JQuery;
import haquery.common.HaqEvent;

class Client extends BaseClient
{
    var event_show : HaqEvent<{ elem : JQuery }>;
    
    var elem : JQuery;
    var timer : haxe.Timer;
    
    public var dataID(default, null) : String;
	
    var mouseOver : JqEvent->Void;
    var mouseOut : JqEvent->Void;
    
    public function init()
    {
        mouseOver = function(e) { elem = new JQuery(e.currentTarget);  innerMouseOver(); };
        mouseOut = function(e) { innerMouseOut(); };
    }

    function innerMouseOver()
    {
        dataID = elem.data(prefixID + "dataID");
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
		template().container.show();
        template().container.offset(getContextPosition(elem));
        event_show.call({ elem:elem });
    }
	
	function hide()
	{
		template().container.hide();
	}
	
	/**
	 * Override if you want to display context panel in the different place.
	 * @param	elem
	 */
	function getContextPosition(elem:JQuery) : { left:Int, top:Int }
	{
		var pos = elem.offset();
		return {
			 left: Math.round(pos.left + elem.width() - template().container.width())
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
    
    function container_mouseover(t, e)
    {
        innerMouseOver();
    }
    
    function container_mouseout(t, e)
    {
        innerMouseOut();
    }
}
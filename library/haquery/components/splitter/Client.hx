#if js

package components.haquery.splitter;

import haquery.client.Lib;
import haquery.client.HaqComponent;
import haquery.client.HaqEvent;
import js.JQuery;

class Client extends HaqComponent
{
    static inline var HORIZONTAL = "horizontal";
    static inline var VERTICAL = "vertical";
	
	/**
     * May be 'horizontal' (by default) or 'vertical'.
     */
	public var type : String;
	
	public var k : Float;
	public var size : Int;

    var event_change : HaqEvent;
	
	var a : JQuery;
	var b : JQuery;

    var mouseupHandler : Dynamic->Void;
    var mousemoveHandler : Dynamic->Void;
	
	var dragMode : Bool;
    var dragMouseX : Int;
    var dragMouseY : Int;
    var dragK : Float;
	
	function new()
	{
		super();
		type = HORIZONTAL;
		
		k = 0.5;
		size = 1;
	}
	
	function init()
    {
        if (type != HORIZONTAL && type != VERTICAL)
		{
			trace("components.splitter - unknow type = " + type);
		}
		
		a = parent.q(q('#a').val()); q('#a').remove();
        b = parent.q(q('#b').val()); q('#b').remove();
		
		untyped q('#s,#f').disableSelection();
        setK(k);
    }

    function setK(k)
    {
        this.k = k;

        a.width(1);
        b.width(1);

        var fullSize = getFullSize();
        var sizeA = Math.floor(fullSize * k) - 2;
        var sizeB = fullSize - sizeA - 2;
        a.width(sizeA);
        b.width(sizeB);

        event_change.call([sizeA, sizeB]);
    }

    function getFullSize()
    {
        var s = q('#s');
        var r = s.parent().width() 
              - s.width()
              - Std.parseInt(s.css('margin-left').split('px')[0])
              - Std.parseInt(s.css('margin-right').split('px')[0])
              - Std.parseInt(a.css('border-left-width').split('px')[0])
              - Std.parseInt(a.css('border-right-width').split('px')[0])
              - Std.parseInt(b.css('border-left-width').split('px')[0])
              - Std.parseInt(b.css('border-right-width').split('px')[0]);
        return r;
    }

    public function setSize(size)
    {
        this.size = size;
        var splitter = q('#s');
        if (splitter.hasClass('splitter-vertical'))
            splitter.css('height', size+'px');
        else if (splitter.hasClass('splitter-horizontal'))
            splitter.css('width', size+'px');
    }

    function s_mousedown(e)
    {
        dragMode = true;
        dragMouseX = e.pageX;
        dragMouseY = e.pageY;
        dragK = k;

        var pos = q('#f').parent().offset();
        q('#f')
            .css('left', pos.left+'px')
            .css('top', pos.top+'px')
            .width(getFullSize())
            .height(size)
            .show();

        var self = this;

        mouseupHandler = function(e) { self.mouseup(e); };
        new JQuery(Lib.document).mouseup(mouseupHandler);

        mousemoveHandler = function(e) { self.mousemove(e); };
        new JQuery(Lib.document).mousemove(mousemoveHandler);
    }
    
    function mouseup(e)
    {
        if (!dragMode) return;
        dragMode = false;
        new JQuery(Lib.document).unbind('mouseup', mouseupHandler);
        new JQuery(Lib.document).unbind('mousemove', mousemoveHandler);
        q('#f').hide();
    }

    function mousemove(e)
    {
        if (!dragMode) return;
        var dx = e.pageX - dragMouseX;
        var dy = e.pageY - dragMouseY;
        var k = dragK + dx / getFullSize();
        setK(k);
    }
}

#end
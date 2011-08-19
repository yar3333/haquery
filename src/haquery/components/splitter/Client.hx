package haquery.components.splitter;

import jQuery.JQuery;
import js.Lib;
import haquery.client.HaqEvent;
import haquery.client.HaqComponent;

class Client extends HaqComponent
{
    public var event_change : HaqEvent;

    var k : Float;
    var size : Int;

    var dragMode : Bool;
    var dragMouseX : Int;
    var dragMouseY : Int;
    var dragK : Float;
    
    var mouseupHandler : Dynamic -> Void;
    var mousemoveHandler : Dynamic -> Void;
    
    public function new ()
    {
        super();

        k = 0.5;
        size = 1;
        
        dragMode = false;
        dragMouseX = 0;
        dragMouseY = 0;
        dragK = 0.0;
    }
    
    
    public function init()
    {
        untyped q('#s,#f').disableSelection();
        setK(k);
    }

    private function setK(k:Float) : Void
    {
        this.k = k;

        var a = parent.q('#'+q('#a').html());
        var b = parent.q('#'+q('#b').html());

        a.width(1);
        b.width(1);

        var fullSize = getFullSize();
        var sizeA = Math.floor(fullSize*k) - 2;
        var sizeB = fullSize - sizeA - 2;
        a.width(sizeA);
        b.width(sizeB);

        event_change.call([sizeA, sizeB]);
    }

    private function getFullSize()
    {
        var s = this.q('#s');
        var a = this.parent.q('#'+this.q('#a').html());
        var b = this.parent.q('#'+this.q('#b').html());
        
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

    public function setSize(size:Int)
    {
        this.size = size;
        var splitter = this.q('#s');
        if (splitter.hasClass('splitter-vertical'))
            splitter.css('height', size+'px');
        else if (splitter.hasClass('splitter-horizontal'))
            splitter.css('width', size+'px');
    }


    private function s_mousedown(e)
    {
        this.dragMode = true;
        this.dragMouseX = e.pageX;
        this.dragMouseY = e.pageY;
        this.dragK = this.k;

        var pos = this.q('#f').parent().offset();
        this.q('#f')
            .css('left', pos.left+'px')
            .css('top', pos.top+'px')
            .width(this.getFullSize())
            .height(this.size)
            .show();

        var self = this;

        mouseupHandler = function(e) { self.mouseup(e); };
        new JQuery(js.Lib.document).mouseup(this.mouseupHandler);

        mousemoveHandler = function(e) { self.mousemove(e); };
        new JQuery(js.Lib.document).mousemove(this.mousemoveHandler);
    }
    
    private function mouseup(e)
    {
        if (!this.dragMode) return;
        this.dragMode = false;
        new JQuery(js.Lib.document).unbind('mouseup', mouseupHandler);
        new JQuery(js.Lib.document).unbind('mousemove', mousemoveHandler);
        this.q('#f').hide();
    }

    private function mousemove(e)
    {
        if (!this.dragMode) return;
        var dx = e.pageX - this.dragMouseX;
        var dy = e.pageY - this.dragMouseY;
        var k = this.dragK + dx / this.getFullSize();
        this.setK(k);
    }
}

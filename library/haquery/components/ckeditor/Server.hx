package haquery.components.ckeditor;

import haquery.server.Lib;
import haquery.server.HaqComponent;
import haquery.server.HaqEvent;

class Server extends HaqComponent
{
    public var text(text_getter, text_setter) : String;
    
    function text_getter()
    {
        return q('#e').html();
    }
    
    function text_setter(v:String)
    {
        q('#e').html(v);
        return v;
    }
    
    function preRender()
    {
		registerScript('ckeditor.js');
    }
}

package components.haquery.ckeditor;

import haquery.server.Lib;
import haquery.server.HaqComponent;
import haquery.common.HaqEvent;

class Server extends HaqComponent
{
    public var text(getText, setText) : String;
    
    function getText()
    {
        return q('#e').html();
    }
    
    function setText(v:String)
    {
        q('#e').html(v);
        return v;
    }
    
    function preRender()
    {
		registerScript('ckeditor.js');
    }
}

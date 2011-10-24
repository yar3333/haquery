package haquery.components.ckeditor;

import haquery.server.Lib;
import haquery.server.HaqComponent;
import haquery.server.HaqEvent;

class Server extends HaqComponent
{
    public var text : String;
    
	var event_save : HaqEvent;
	
    function init()
    {
        if (Lib.isPostback)
        {
            text = q('#t').val();
        }
    }
    
    function preRender()
    {
		manager.registerScript(tag, 'ckeditor.js');
        q('#e').html(text);
    }
    
    function b_click()
    {
        event_save.call([text]);
    }
}

package haquery.components.ckeditor;

import haquery.server.Lib;
import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    public var text : String;
    
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
}

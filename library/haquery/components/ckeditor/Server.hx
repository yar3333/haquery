package haquery.components.ckeditor;

import haquery.server.Lib;
import haquery.server.HaqComponent;
import haquery.server.HaqEvent;

class Server extends HaqComponent
{
    public var text : String;
	
    function init()
    {
        if (!Lib.isPostback)
        {
			if (text == null)
			{
				text = parentNode.innerHTML;
				parentNode.innerHTML = '';
			}
        }
        else
        {
            text = q('#e').val();
        }
    }
    
    function preRender()
    {
		manager.registerScript(tag, 'ckeditor.js');
        q('#e').html(text);
    }
}

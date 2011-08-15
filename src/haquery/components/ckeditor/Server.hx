package haquery.components.ckeditor;

import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    public var text : String;
    
	function preRender()
    {
		manager.registerScript(tag, '~/ckeditor.js');
        q('#e').html(text);
    }
}

package haquery.components.ckeditor;

import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    public var text : String;
    
	public function new()
	{
		super();
		manager.registerScript(tag, '~/ckeditor.js');
	}
    
	function preRender()
    {
        q('#e').html(text);
    }
}

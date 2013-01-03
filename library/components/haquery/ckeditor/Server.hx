package components.haquery.ckeditor;

class Server extends BaseServer
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

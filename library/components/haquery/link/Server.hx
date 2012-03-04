package components.haquery.link;

class Server extends Base
{
    public var href : String;
    public var text : String;
	public var cssClass : String;
	
    function preRender()
	{
        q('#href').val(href);
        link.text = text;
		link.cssClass = cssClass;
	}
}

package haquery.components.link;

class Server extends Base
{
    public var href : String;
    public var text : String;
	public var cssClass : String;
	public var style : String;
	public var hidden : Bool;
	
    public function preRender()
	{
        q('#href').val(href);
        link.text = text;
		link.cssClass = cssClass;
		link.style = style;
		link.hidden = hidden;
	}
}

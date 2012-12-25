package components.haquery.link;

class Server extends Base
{
    public var href : String;
    public var text : String;
	public var cssClass : String;
	
    function preRender()
	{
        template().href.val(href);
        template().text = text;
		template().cssClass = cssClass;
	}
}

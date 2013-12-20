package components.haquery.fileupload;

class Server extends Base
{
    public var action : String = null;
    public var accept : String = null;
	
	function preRender()
    {
		template().form
			.attr("target", prefixID + "frame")
			.attr("action", action);
		
		template().file.attr("accept", accept);
		
        template().frame.attr("name", prefixID + "frame");
    }
}

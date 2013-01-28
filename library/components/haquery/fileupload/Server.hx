package components.haquery.fileupload;

class Server extends Base
{
    function preRender()
    {
		template().form.attr("target", prefixID + "frame");
        template().frame.attr("name", prefixID + "frame");
    }
}

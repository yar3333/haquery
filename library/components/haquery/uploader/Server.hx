package components.haquery.uploader;

class Server extends Base
{
    public var filter = "";

    function preRender()
    {
		template().form.attr("target", prefixID + "frame");
        template().frame.attr("name", prefixID + "frame");
        template().frame.data("filter", filter);
    }
}

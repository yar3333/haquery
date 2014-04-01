package components.haquery.literal;

class Server extends BaseServer
{
    public var text : String;
	
    override function renderDirect()
	{
        return text != null ? text : "";
	}
}
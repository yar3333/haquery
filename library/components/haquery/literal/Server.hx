package components.haquery.literal;

class Server extends BaseServer
{
    public var text : String;
	
    override function render()
	{
        return text != null ? text : "";
	}
}
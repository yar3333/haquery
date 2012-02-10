package haquery.components.literal;

import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    public var text : String;
	
    override function render()
	{
        return text != null ? text : "";
	}
}
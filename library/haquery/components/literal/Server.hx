package haquery.components.literal;

import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    public var text : String;
	
    function render()
	{
        return text;
	}
}
package components.haquery.alternative;

import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    public var active : Int;
    
    function new()
    {
        super();
        active = 0;
    }
    
    function preRender()
    {
        for  (i in 0...active)
        {
			if (innerNode.children.length == 0) break;
            innerNode.children[0].remove();
        }
        
        while (innerNode.children.length > 1)
        {
			innerNode.children[1].remove();
        }
    }
}
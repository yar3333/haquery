package components.haquery.alternative;

import haquery.server.HaqComponent;
import haquery.server.Lib;
import haquery.server.HaqXml;

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
			if (parentNode.children.length == 0) break;
            parentNode.children[0].remove();
        }
        
        while (parentNode.children.length > 1)
        {
			parentNode.children[1].remove();
        }
    }
}
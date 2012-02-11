package components.haquery.alternative;

import haquery.server.Lib;
import haquery.server.HaqXml;

using php.NativeArrayTools;

class Server extends components.haquery.container.Server
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
			if (parentNode.children.count() == 0) break;
            parentNode.children[0].remove();
        }
        
        while (parentNode.children.count() > 1)
        {
			parentNode.children[1].remove();
        }
    }
}
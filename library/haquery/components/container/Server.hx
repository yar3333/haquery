package haquery.components.container;

import haquery.server.HaqComponent;

using haquery.server.HaqComponentTools;
using haquery.StringTools;

class Server extends HaqComponent
{
    override public function render():String 
    {
        expandDocElemIDs();
        
        return doc.toString().trim("\r\n").replace("{content}", parentNode.innerHTML);
    }
}

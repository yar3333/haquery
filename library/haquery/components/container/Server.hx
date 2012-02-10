package haquery.components.container;

import haquery.server.HaqComponent;

using haquery.StringTools;

class Server extends HaqComponent
{
    override public function render():String 
    {
        manager.prepareDocToRender(prefixID, doc);
        
        return doc.toString().trim("\r\n").replace("{content}", parentNode.innerHTML);
    }
}

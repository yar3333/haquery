package haquery.components.container;

import haquery.server.HaqComponent;
import haquery.server.HaqComponentManager;
import haquery.server.HaqXml;

using haquery.StringTools;

class Server extends Base
{
    override public function render():String 
    {
        prepareDocToRender(doc);
        
        return doc.toString().trim("\r\n").replace("{content}", parentNode.innerHTML);
    }
    
/*  override function callElemEventHandler(elemID:String, eventName:String) : Void
    {
        if (parent != null)
        {
            var handler = elemID + '_' + eventName;
            Reflect.callMethod(parent, handler, [ this ]);
        }
    }*/
}

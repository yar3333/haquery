package haquery.components.helper;

import haquery.server.HaqXml;
import haquery.server.Lib;
import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    public var selector : String;
    
    function new(?selector:String)
    {
        super();
        this.selector = selector;
    }
    
    function preRender()
    {
        if (selector != null)
        {
            doc.addChild(new HaqXmlNodeText("\n<input type='hidden' id='" + prefixID + "selector' value='" + selector + "' />"));
        }
    }
}
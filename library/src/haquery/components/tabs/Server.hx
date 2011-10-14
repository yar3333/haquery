package haquery.components.tabs;

import haquery.server.HaqComponent;
import haquery.server.HaqQuery;
import haquery.server.Lib;
import php.Lib;
import haquery.server.HaqXml;

class Server extends haquery.components.container.Server
{
    public var active : Int;
    
    public function new()
    {
        super();
        active = 0;
    }
    
    function init()
    {
        if (!isPostback)
        {
            var buttonsAndPanels : Array<HaqXmlNodeElement> = cast Lib.toHaxeArray(parentNode.children);
            Lib.assert(buttonsAndPanels.length == 2, "tabs component must contain exactly two subelements.");
            
            var buttons = buttonsAndPanels[0].children;
            var i = 0;
            for (child in Lib.toHaxeArray(buttons))
            {
                if (i == active) new HaqQuery(prefixID, "", Lib.toPhpArray([child])).addClass('active');
                i++;
            }
            
            var panels = buttonsAndPanels[1].children;
            var j = 0;
            for (child in Lib.toHaxeArray(panels))
            {
                if (j == active) new HaqQuery(prefixID, "", Lib.toPhpArray([child])).addClass('active');
                j++;
            }
        }
    }
}

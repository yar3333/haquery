package haquery.components.tabs;

import haquery.server.HaqComponent;
import haquery.server.HaqQuery;
import haquery.server.HaQuery;
import php.Lib;

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
            var buttonsAndPanels = q('#tabs>*');
            var buttons = buttonsAndPanels.nodes[0];
            var i = 0;
            for (child in Lib.toHaxeArray(buttons.children))
            {
                if (i == active) new HaqQuery(prefixID, "", Lib.toPhpArray([child])).addClass('active');
                i++;
            }
            
            var panels = q('#tabs>*').nodes[1];
            var j = 0;
            for (child in Lib.toHaxeArray(panels.children))
            {
                if (j == active) new HaqQuery(prefixID, "", Lib.toPhpArray([child])).addClass('active');
                j++;
            }
        }
    }
    
    override private function getHeader():String 
    {
        return '<div id="tabs" class="tabs">\n';
    }
    
    override private function getFooter():String 
    {
        return '</div>\n';
    }
}

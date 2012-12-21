package components.haquery.tabs;

import haquery.server.Lib;

class Server extends BaseServer
{
    public var active = 0;
    
    function preRender()
    {
		var buttonsAndPanels = innerNode.children;
		Lib.assert(buttonsAndPanels.length == 2, "Tabs component must contain exactly two subelements.");
		
		var buttons = buttonsAndPanels[0].children;
		var i = 0;
		for (child in buttons)
		{
			if (i == active)
			{
				q(child).addClass('active');
			}
			i++;
		}
		
		var panels = buttonsAndPanels[1].children;
		var j = 0;
		for (child in panels)
		{
			if (j == active)
			{
				q(child).addClass('active');
			}
			j++;
		}
    }
}

package components.haquery.tabs;

import haquery.server.Lib;

class Server extends BaseServer
{
    public var activeIndex = 0;
	public var cssClass = "";
    
    function preRender()
    {
		Lib.assert(innerNode.children.length >= 1 && innerNode.children.length <= 2, "Tabs component must contain one or two subelements.");
		
		var buttonsAndPanels = innerNode.children;
		
		var buttons = buttonsAndPanels[0].children;
		var i = 0;
		for (child in buttons)
		{
			if (i == activeIndex)
			{
				q(child).addClass('active');
			}
			i++;
		}
		
		if (buttonsAndPanels.length > 1)
		{
			var panels = buttonsAndPanels[1].children;
			var j = 0;
			for (child in panels)
			{
				if (j == activeIndex)
				{
					q(child).addClass('active');
				}
				j++;
			}
		}
		
		template().container.addClass(cssClass);
    }
}

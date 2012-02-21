package haquery.components.container;

import haquery.server.HaqComponent;
import haquery.server.HaqXml;

using haquery.StringTools;
using haquery.server.HaqComponentTools;

class Server extends HaqComponent
{
    var customRenderComponents : Array<HaqComponent>;
	
	function new()
	{
		super();
	}
	
	override function createChildComponents()
	{
		if (parentNode != null)
		{
			customRenderComponents = manager.createDocComponents(parent, parentNode, true);
		}
		
		if (doc != null)
		{
			manager.createDocComponents(this, doc, false);
		}
	}
	
	override public function render():String 
    {
        if (!visible) return "";
		
		for (child in customRenderComponents)
		{
			child.parentNode.parent.replaceChild(child.parentNode, new HaqXmlNodeText(child.render()));
		}
		var text = super.render().replace("{content}", parentNode.innerHTML);
		
		return text;
    }
}

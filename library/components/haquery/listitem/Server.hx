package components.haquery.listitem;

import haquery.server.HaqComponent;
import haquery.server.HaqTemplateManager;
import haxe.htmlparser.HtmlDocument;
import haxe.htmlparser.HtmlNodeElement;

class Server extends Base
{
	override public function construct(manager:HaqTemplateManager, fullTag:String, parent:HaqComponent, id:String, doc:HtmlDocument, params:Hash<Dynamic>, innerNode:HtmlNodeElement, isInnerComponent:Bool):Void 
	{
        var xml = Tools.applyHtmlParams(innerNode.innerHTML, params);
        super.construct(manager, fullTag, parent, id, xml, params, null, isInnerComponent);
	}
    
	override function createChildComponents()
	{
		if (doc != null)
		{
			manager.createDocComponents(this, doc, false);
		}
		
		forEachComponent("preInit", true);
		forEachComponent("init", false);		
	}
	
	override function callElemEventHandler(elemID:String, eventName:String) : Dynamic
    {
        if (parent != null && parent.parent != null)
        {
            var handler = elemID + '_' + eventName;
            return Reflect.callMethod(parent.parent, handler, [ this, null ]);
        }
		return null;
    }
}

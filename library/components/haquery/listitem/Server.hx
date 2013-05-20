package components.haquery.listitem;

import haquery.server.Lib;
import haquery.server.HaqComponent;
import haxe.htmlparser.HtmlDocument;
import haxe.htmlparser.HtmlNodeElement;

class Server extends Base
{
	override public function construct(fullTag:String, parent:HaqComponent, id:String, doc:HtmlDocument, params:Hash<Dynamic>, innerNode:HtmlNodeElement, isInnerComponent:Bool):Void 
	{
        var xml = Tools.applyHtmlParams(innerNode.innerHTML, params);
        super.construct(fullTag, parent, id, xml, params, null, isInnerComponent);
	}
    
	override function createChildComponents()
	{
		if (doc != null)
		{
			Lib.manager.createDocComponents(this, doc, false);
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

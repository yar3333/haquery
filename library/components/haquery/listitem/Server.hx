package components.haquery.listitem;

import haquery.server.HaqComponent;
import haquery.server.HaqTemplateManager;
import haquery.server.HaqTemplate;
import haxe.htmlparser.HtmlDocument;
import haxe.htmlparser.HtmlNodeElement;

class Server extends Base
{
	override public function construct(manager:HaqTemplateManager, fullTag:String, parent:HaqComponent, id:String, doc:HtmlDocument, params:Hash<String>, innerNode:HtmlNodeElement, isInnerComponent:Bool):Void 
	{
		var innerHTML = innerNode.innerHTML;
        
        if (params != null)
		{
            var reConsts = new EReg("[{]([_a-zA-Z][_a-zA-Z0-9]*)[}]", "");
            
            innerHTML = reConsts.customReplace(innerHTML, function(re) 
            {
                var const = re.matched(1);
                if (params.exists(const))
                {
                    return params.get(const);
                }
                return re.matched(0);
            });
        }
        
        var xml = null;
        try
        {
            xml = new HtmlDocument(innerHTML);
        }
        catch (e:Dynamic)
        {
            trace("XML parse error:\n" + innerHTML);
            xml = new HtmlDocument('XML parse error.');
        }
        
        super.construct(manager, fullTag, parent, id, xml, params, null, isInnerComponent);
	}
    
	override function createChildComponents()
	{
		if (doc != null)
		{
			manager.createDocComponents(this, doc, false);
		}
	}
	
	override function callElemEventHandler(elemID:String, eventName:String) : Dynamic
    {
        if (parent != null && parent.parent != null)
        {
            var handler = elemID + '_' + eventName;
            return Reflect.callMethod(parent.parent, handler, [ this ]);
        }
		return null;
    }
}

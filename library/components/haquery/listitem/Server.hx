package components.haquery.listitem;

import haquery.server.HaqComponent;
import haquery.server.HaqComponentManager;
import haquery.server.HaqTemplate;
import haquery.server.HaqXml;

class Server extends Base
{
	override public function construct(manager:HaqComponentManager, fullTag:String, parent:HaqComponent, id:String, doc:HaqXml, params:Hash<String>, parentNode:HaqXmlNodeElement):Void 
	{
		var innerHTML = parentNode.innerHTML;
        
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
            xml = new HaqXml(innerHTML);
        }
        catch (e:Dynamic)
        {
            trace("XML parse error:\n" + innerHTML);
            xml = new HaqXml('XML parse error.');
        }
        
        super.construct(manager, fullTag, parent, id, xml, params, null);
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

package haquery.components.listitem;

import haquery.server.HaqComponent;
import haquery.server.HaqComponentManager;
import haquery.server.HaqXml;

class Server extends Base
{
	override public function construct(manager:HaqComponentManager, parent:HaqComponent, tag:String, id:String, doc:HaqXml, params:Hash<String>, innerHTML:String):Void 
	{
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
        
        var doc = new HaqXml(innerHTML);
        
        super.construct(manager, parent, tag, id, doc , params, '');
	}
    
    override function callElemEventHandler(elemID:String, eventName:String) : Void
    {
        if (parent != null && parent.parent != null)
        {
            var handler = elemID + '_' + eventName;
            Reflect.callMethod(parent.parent, handler, [ this ]);
        }
    }
}

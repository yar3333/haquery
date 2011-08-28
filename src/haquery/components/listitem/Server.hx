package haquery.components.listitem;

import haquery.server.HaqComponent;
import haquery.server.HaqComponentManager;
import haquery.server.HaqXml;

class Server extends Base
{
	override public function construct(manager:HaqComponentManager, parent:HaqComponent, tag:String, id:String, doc:HaqXml, params:Dynamic, innerHTML:String):Void 
	{
		if (params != null)
		{
            var reConsts = new EReg("[{]([_a-zA-Z][_a-zA-Z0-9]*)[}]", "");
            
            if (Type.getClassName(Type.getClass(params)) == "Hash")
            {
                var paramsAsHash : Hash<String> = cast params;
                while (reConsts.match(innerHTML))
                {
                    var const = reConsts.matched(1);
                    if (paramsAsHash.exists(const))
                    {
                        innerHTML = innerHTML.replace('{' + const + '}', paramsAsHash.get(const));
                    }
                }
            }
            else
            {
                while (reConsts.match(innerHTML))
                {
                    var const = reConsts.matched(1);
                    if (Reflect.hasField(params, const))
                    {
                        innerHTML = innerHTML.replace('{' + const + '}', Reflect.field(params, const));
                    }
                }
            }
        }
        
        var doc = new HaqXml(innerHTML);
        
        super.construct(manager, parent, tag, id, doc , params, '');
	}
    
    override function callElemEventHandler(elemID:String, eventName:String) : Void
    {
        if (parent != null && parent.parent != null)
        {
            var handler = elemID + '_' + eventName;
            Reflect.callMethod(parent.parent, handler, [this]);
        }
    }
}

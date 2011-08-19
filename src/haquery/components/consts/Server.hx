package haquery.components.consts;

import haquery.server.HaqComponent;
import haquery.server.HaqComponentManager;
import haquery.server.HaqXml;

class Server extends HaqComponent
{
    public static var consts : Hash<String> = new Hash<String>();
    
	override public function construct(manager:HaqComponentManager, parent:HaqComponent, tag:String, id:String, doc:HaqXml, params:Hash<String>, innerHTML:String):Void 
	{
        for (const in consts.keys())
        {
            innerHTML = innerHTML.replace('{' + const + '}', consts.get(const));
        }
		
        super.construct(manager, parent, tag, id, new HaqXml(innerHTML) , params, '');
	}
}
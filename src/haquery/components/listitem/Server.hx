package haquery.components.listitem;

import php.Lib;
import php.Web;
import haquery.server.HaqComponent;
import haquery.server.HaqComponentManager;
import haquery.server.HaqEvent;
import haquery.server.HaqInternals;
import haquery.server.HaqXml;
import haquery.server.HaQuery;

class Server extends HaqComponent
{
	override public function construct(manager:HaqComponentManager, parent:HaqComponent, tag:String, id:String, doc:HaqXml, params:Hash<String>, innerHTML:String):Void 
	{
		doc = new HaqXml(innerHTML);
		
		if (params!=null && params.exists('seralizedParams'))
		{
			var childrenParams : Hash<Hash<String>> = untyped Lib.unserialize(params.get('seralizedParams'));
			for (id in childrenParams.keys())
			{
				var elems : Array<HaqXmlNodeElement> = untyped Lib.toHaxeArray(doc.find('#' + id));
				for (e in elems)
				{
					var childrenAttrs : Hash<String> = childrenParams.get(id);
					for (attrName in childrenAttrs.keys())
					{
						e.setAttribute(attrName, childrenAttrs.get(attrName));
					}
				}
			}
		}
		
		super.construct(manager, parent, tag, id, doc , params, '');
	}
	
	override public function connectEventHandlers(child:HaqComponent, event:HaqEvent) : Void
	{
		var handlerName = parent.id + '_' + child.id + '_' + event.name;
		//trace("Check event handler exist " + handlerName);
		if (Reflect.hasMethod(parent.parent, handlerName))
		{
			//trace("YES: " + handlerName);
			event.bind(parent.parent, Reflect.field(parent.parent, handlerName));
		}
	}
}

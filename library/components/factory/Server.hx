package haquery.components.factory;

import haquery.server.Lib;
import haquery.server.HaqComponent;
import haxe.Serializer;

class Server extends Base
{
	public var component : String;
	
    override function createChildComponents():Void 
	{
        if (Lib.isPostback)
        {
			for (i in 0...length)
			{
				manager.createComponent(this, component, Std.string(i), null, parentNode);
			}
        }
	}

	function preRender()
    {
        q('#component').val(component);
		q('#template').val(Serializer.run(manager.getTemplateHtml(tag)));
	}
	
    override function callElemEventHandler(elemID:String, eventName:String) : Dynamic
    {
        if (parent != null)
        {
            var handler = elemID + '_' + eventName;
            return Reflect.callMethod(parent, handler, [ this ]);
        }
		return null;
    }
}
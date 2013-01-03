package haquery.client;

#if client

import js.Dom;
import js.JQuery;
import haquery.client.Lib;
import haquery.common.HaqDefines;

class HaqElemEventManager 
{
    public static function connect(componentWithHandlers:HaqComponent, componentWithEvents:HaqComponent, manager:HaqTemplateManager)
    {
        var elems:Array<HtmlDom> = getComponentElems(componentWithEvents);
        
        for (elem in elems)
        {
            var n = elem.id.lastIndexOf(HaqDefines.DELIMITER);
            var elemID = n != -1 ? elem.id.substr(n + 1) : elem.id;
            for (eventName in HaqDefines.elemEventNames)
            {
                var needHandler = Reflect.isFunction(Reflect.field(componentWithHandlers, elemID + "_" + eventName));
                if (!needHandler)
                {
                    var serverHandlers = manager.get(componentWithHandlers.fullTag).serverHandlers;
                    needHandler = serverHandlers != null && Lambda.has(serverHandlers, elemID + "_" + eventName);
                }
                if (needHandler)
                {
                    new JQuery(elem).bind(eventName, function(e:JqEvent) {
                        elemEventHandler(componentWithHandlers, componentWithEvents, elem, manager, e); 
                    });
                }
            }
        }
    }

    static function getComponentElems(component:HaqComponent) : Array<HtmlDom>
    {
		var re = new EReg('^' + component.prefixID + '[^' + HaqDefines.DELIMITER + ']+$', '');
        
        var r = new Array<HtmlDom>();
        for (elem in new JQuery("[id]").toArray())
        {
            if (re.match(elem.id))
            {
                r.push(elem);
            }
        }
        
        return r;
    }
	
	static function elemEventHandler(componentWithHandlers:HaqComponent, componentWithEvents:HaqComponent, elem:HtmlDom, manager:HaqTemplateManager, e:JqEvent)
    {
		if (callClientElemEventHandlers(componentWithHandlers, componentWithEvents, elem, e))
		{
			var serverHandlers = manager.get(componentWithHandlers.fullTag).serverHandlers;
			callServerElemEventHandlers(elem.id, e.type, serverHandlers);
		}
    }
	
	static function callClientElemEventHandlers(componentWithHandlers:HaqComponent, componentWithEvents:HaqComponent, elem:HtmlDom, e:JqEvent) : Bool
	{
		var n = elem.id.lastIndexOf(HaqDefines.DELIMITER);
		var elemID = n > 0 ? elem.id.substr(n + 1) : elem.id;
		var methodName = elemID + "_" + e.type;
		if (Reflect.isFunction(Reflect.field(componentWithHandlers, methodName)))
		{
			var r = Reflect.callMethod(componentWithHandlers, Reflect.field(componentWithHandlers, methodName), [ componentWithEvents, e ]);
			if (r == false) return false;
		}
		return true;
	}
	
	static function callServerElemEventHandlers(fullElemID:String, event:String, serverHandlers:Array<String>) : Bool
	{
		var n = fullElemID.lastIndexOf(HaqDefines.DELIMITER);
		var elemID = n > 0 ? fullElemID.substr(n + 1) : fullElemID;
        
		if (serverHandlers != null && Lambda.has(serverHandlers, elemID + "_" + event))
		{
			var componentID = n > 0 ? fullElemID.substr(0, n) : "";
			Lib.ajax.callSharedMethod(componentID, elemID + "_" + event);
		}
		
        return true;
	}
}

#end
package haquery.client;

import js.Dom;
import js.Lib;
using haquery.StringTools;

class HaqElemEventManager 
{
    static var elemEventNames : Array<String> = [
		'click', 'change', 'load',
		'mousedown', 'mouseup', 'mousemove',
		'mouseover', 'mouseout', 'mouseenter', 'mouseleave',
		'keypress', 'keydown', 'keyup', 
		'focus', 'focusin', 'focusout',
    ];
	
    static var elems(elems_getter, null) : Array<HtmlDom>;
    static var elems_cached : Array<HtmlDom>;
    static function elems_getter() : Array<HtmlDom>
    {
        if (elems_cached == null)
        {
            elems_cached = (new HaqQuery("*[id]")).toArray();
        }
        return elems_cached;
    }
    
    public static function getComponentElems(component:HaqComponent) : Array<HtmlDom>
    {
        var re = new EReg('^' + component.prefixID + '[^' + HaqInternals.DELIMITER + ']+$', '');
        
        var r = new Array<HtmlDom>();
        for (elem in elems)
        {
            if (re.match(elem.id))
            {
                r.push(elem);
            }
        }
        
        return r;
    }
	
    public static function connect(componentWithHandlers:HaqComponent, componentWithEvents:HaqComponent, templates:HaqTemplates)
    {
        var elems:Array<HtmlDom> = getComponentElems(componentWithEvents);
        
        for (elem in elems)
        {
            var n = elem.id.lastIndexOf(HaqInternals.DELIMITER);
            var elemID = n != -1 ? elem.id.substr(n + 1) : elem.id;
            for (eventName in elemEventNames)
            {
                var needHandler = Reflect.isFunction(Reflect.field(componentWithHandlers, elemID + "_" + eventName));
                if (!needHandler)
                {
                    var serverHandlers = templates.get(componentWithHandlers.tag).elemID_serverHandlers;
                    if (serverHandlers != null && serverHandlers.get(elemID) != null 
                     && Lambda.has(serverHandlers.get(elemID), eventName)
                    ) {
                        needHandler = true;
                    }
                }
                if (needHandler)
                {
                    new HaqQuery(elem).bind(eventName, null, function(e:js.Dom.Event):Bool {
                        return elemEventHandler(componentWithHandlers, componentWithEvents, elem, templates, e); 
                    });
                }
            }
        }
    }

    static function elemEventHandler(componentWithHandlers:HaqComponent, componentWithEvents:HaqComponent, elem:HtmlDom, templates:HaqTemplates, e:js.Dom.Event) : Bool
    {
		var r = callClientElemEventHandlers(componentWithHandlers, componentWithEvents, elem, e);
		if (!r) return false;
        
		var serverHandlers = templates.get(componentWithHandlers.tag).elemID_serverHandlers;
        return callServerElemEventHandlers(elem, e, serverHandlers);
    }
	
	static function callClientElemEventHandlers(componentWithHandlers:HaqComponent, componentWithEvents:HaqComponent, elem:HtmlDom, e:js.Dom.Event) : Bool
	{
		var n = elem.id.lastIndexOf(HaqInternals.DELIMITER);
		var elemID = n > 0 ? elem.id.substr(n + 1) : elem.id;
		var methodName = elemID + "_" + e.type;
		if (Reflect.isFunction(Reflect.field(componentWithHandlers, methodName)))
		{
			var r = Reflect.callMethod(componentWithHandlers, Reflect.field(componentWithHandlers, methodName), [ componentWithEvents, e ]);
			if (r == false) return false;
		}
		return true;
	}
	
	static function callServerElemEventHandlers(elem:HtmlDom, e:js.Dom.Event, serverHandlers:Hash<Array<String>>) : Bool
	{
		var n = elem.id.lastIndexOf(HaqInternals.DELIMITER);
		var elemID = n > 0 ? elem.id.substr(n + 1) : elem.id;
        
        if (serverHandlers != null && serverHandlers.get(elemID) != null)
        {
            var handlers = serverHandlers.get(elemID);
            if (!Lambda.has(handlers, e.type)) return true;  // серверного обработчика нет

            var sendData = getDataObjectForSendToServer(elem.id, e.type);
            HaqQuery._static.post(Lib.window.location.href, sendData, callServerHandlersCallbackFunction);
		}
		
        return true;
	}
    
    public static function callServerHandlersCallbackFunction(data:String) : Void
    {
        var okMsg = "HAQUERY_OK";
        if (data.startsWith(okMsg))
        {
            var code = data.substr(okMsg.length);
            trace("AJAX: "+code);
            untyped __js__("eval(code)");
        }
        else
        {
            if (data != '')
            {
                var errWin = Lib.window.open("", "HAQUERY_ERROR_AJAX");
                errWin.document.write(data);
            }
        }
    }
    
    public static function getDataObjectForSendToServer(fullElemID:String, eventType:String) : Dynamic
    {
        var sendData : Dynamic = {};
        sendData[untyped 'HAQUERY_POSTBACK'] = 1;
        sendData[untyped 'HAQUERY_ID'] = fullElemID;
        sendData[untyped 'HAQUERY_EVENT'] = eventType;

        for (sendElem in getElemsForSendToServer(fullElemID))
        {
            sendData[untyped sendElem.id] = sendElem.nodeName.toUpperCase() == 'INPUT' && sendElem.getAttribute('type').toUpperCase() == "CHECKBOX"
                ? (Reflect.field(sendElem, 'checked') ? new HaqQuery(sendElem).val() : '')
                : new HaqQuery(sendElem).val();
        }
        
        return sendData;
    }
	
	static function getElemsForSendToServer(fullElemID:String) : Iterable<HtmlDom>
	{
		var jqAllElemsWithID = new HaqQuery("[id]");
		var allElemsWithID : Array<HtmlDom> = untyped jqAllElemsWithID.toArray();
		var elems = Lambda.filter(allElemsWithID, function(elem:HtmlDom):Bool {
            var elemTag = elem.nodeName.toUpperCase();
            var elemType = elemTag=="INPUT" ? elem.getAttribute('type').toUpperCase() : '';
            return elemTag == "INPUT" && Lambda.has(["TEXT", "PASSWORD", "HIDDEN", "CHECKBOX", "RADIO"], elemType)
				|| elemTag == "TEXTAREA"
				|| elemTag == "SELECT";
		});
		
		return elems;
	}
}
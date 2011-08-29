package haquery.client;

import js.Dom;
import js.Lib;

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
                var needHandler = Reflect.hasMethod(componentWithHandlers, elemID + "_" + eventName);
                if (!needHandler)
                {
                    var serverHandlers = templates.get(componentWithHandlers.tag).elemID_serverHandlers;
                    if (serverHandlers != null && serverHandlers.get(elemID) != null 
                     && serverHandlers.get(elemID).indexOf(eventName) != -1
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
        return callServerElemEventHandlers(elem, componentWithEvents, e, serverHandlers);
    }
	
	static function callClientElemEventHandlers(componentWithHandlers:HaqComponent, componentWithEvents:HaqComponent, elem:HtmlDom, e:js.Dom.Event) : Bool
	{
		var n = elem.id.lastIndexOf(HaqInternals.DELIMITER);
		var elemID = n > 0 ? elem.id.substr(n + 1) : elem.id;
		var methodName = elemID + "_" + e.type;
		if (Reflect.hasMethod(componentWithHandlers, methodName))
		{
			var r = Reflect.callMethod(componentWithHandlers, Reflect.field(componentWithHandlers, methodName), [ HaqEventTarget.elem(new HaqQuery(elem)), e ]);
			if (r == false) return false;
		}
		return true;
	}
	
	static function callServerElemEventHandlers(elem:HtmlDom, componentWithEvents:HaqComponent, e:js.Dom.Event, serverHandlers:Hash<Array<String>>) : Bool
	{
		var n = elem.id.lastIndexOf(HaqInternals.DELIMITER);
		var elemID = n > 0 ? elem.id.substr(n + 1) : elem.id;
        
        if (serverHandlers != null && serverHandlers.get(elemID) != null)
        {
            var handlers = serverHandlers.get(elemID);
            if (handlers.indexOf(e.type)==-1) return true;  // серверного обработчика нет

            var sendData : Dynamic = {};
            sendData[untyped 'HAQUERY_POSTBACK'] = 1;
            sendData[untyped 'HAQUERY_ID'] = elem.id;
            sendData[untyped 'HAQUERY_EVENT'] = e.type;

            for (sendElem in getElemsForSendToServer(elem.id))
            {
                sendData[untyped sendElem.id] = sendElem.nodeName.toUpperCase() == 'INPUT' && sendElem.getAttribute('type').toUpperCase() == "CHECKBOX"
                    ? (Reflect.field(sendElem, 'checked') ? new HaqQuery(sendElem).val() : '')
                    : new HaqQuery(sendElem).val();
            }
            
            HaqQuery._static.post(
                Lib.window.location.href,
                sendData,
                function(data:String) : Void
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
            );
		}
		
        return true;
	}
	
	static function getElemsForSendToServer(fullElemID:String) : Iterable<HtmlDom>
	{
		var ids : Array<String> = fullElemID.split(HaqInternals.DELIMITER);
		var reStr = '(^[^' + HaqInternals.DELIMITER + ']+$)';
		for (i in 0...ids.length)
		{
			var s = '(^' + ids.slice(0, i + 1).join(HaqInternals.DELIMITER) + HaqInternals.DELIMITER + '[^' + HaqInternals.DELIMITER + ']+$)';
			reStr += '|' + s;
		}
        trace('reStr = ' + reStr);
		var re : EReg = new EReg(reStr, '');
		
		var jqAllElemsWithID = new HaqQuery("[id]");
		var allElemsWithID : Array<HtmlDom> = untyped jqAllElemsWithID.toArray();
		var elems = Lambda.filter(allElemsWithID, function(elem:HtmlDom):Bool {
			if (!re.match(elem.id)) return false;
            var elemTag = elem.nodeName.toUpperCase();
            var elemType = elemTag=="INPUT" ? elem.getAttribute('type').toUpperCase() : '';
            return elemTag == "INPUT" && Lambda.has(["PASSWORD", "HIDDEN", "CHECKBOX", "RADIO"], elemType)
				|| elemTag == "TEXTAREA"
				|| elemTag == "SELECT";
		});
		
		return elems;
	}
}
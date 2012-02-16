package haquery.client;

import haxe.Serializer;
import haxe.Unserializer;
import js.Dom;
import js.Lib;
import js.JQuery;

using haquery.StringTools;

class HaqElemEventManager 
{
    static var elems(elems_getter, null) : Array<HtmlDom>;
    static var elems_cached : Array<HtmlDom>;
    static function elems_getter() : Array<HtmlDom>
    {
        if (elems_cached == null)
        {
            elems_cached = (new JQuery("*[id]")).toArray();
        }
        return elems_cached;
    }
	
	public static function elemsWasChanged()
	{
		elems_cached = null;
	}
    
    public static function getComponentElems(component:HaqComponent) : Array<HtmlDom>
    {
		var re = new EReg('^' + component.prefixID + '[^' + HaqDefines.DELIMITER + ']+$', '');
        
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
            var n = elem.id.lastIndexOf(HaqDefines.DELIMITER);
            var elemID = n != -1 ? elem.id.substr(n + 1) : elem.id;
            for (eventName in HaqDefines.elemEventNames)
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
                    new JQuery(elem).bind(eventName, function(e:JqEvent) {
                        elemEventHandler(componentWithHandlers, componentWithEvents, elem, templates, e); 
                    });
                }
            }
        }
    }

    static function elemEventHandler(componentWithHandlers:HaqComponent, componentWithEvents:HaqComponent, elem:HtmlDom, templates:HaqTemplates, e:JqEvent)
    {
		if (callClientElemEventHandlers(componentWithHandlers, componentWithEvents, elem, e))
		{
			var serverHandlers = templates.get(componentWithHandlers.tag).elemID_serverHandlers;
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
	
	public static function callServerElemEventHandlers(fullElemID:String, event:String, serverHandlers:Hash<Array<String>>) : Bool
	{
		var n = fullElemID.lastIndexOf(HaqDefines.DELIMITER);
		var elemID = n > 0 ? fullElemID.substr(n + 1) : fullElemID;
        
		if (serverHandlers != null && serverHandlers.get(elemID) != null)
		{
			if (Lambda.has(serverHandlers.get(elemID), event))
			{
				var componentID = n > 0 ? fullElemID.substr(0, n) : "";
				callServerMethod(componentID, elemID + "_" + event);
			}
		}
		
        return true;
	}
    
	public static function callServerMethod(componentID:String, method:String, ?params:Array<Dynamic>, ?callbackFunc:Dynamic->Void) : Void
	{
		var sendData = getDataObjectForSendToServer(componentID, method, params);
		untyped JQuery.post(Lib.window.location.href, sendData, function(data:String) : Void
		{ 
			callServerHandlersCallbackFunction(data, callbackFunc);
		});
	}
	
	public static function callServerHandlersCallbackFunction(data:String, ?callbackFunc:Dynamic->Void) : Void
	{
		var okMsg = "HAQUERY_OK";
		if (data.startsWith(okMsg))
		{
			var resultAndCode = data.substr(okMsg.length);
			var n = resultAndCode.indexOf("\n");
			if (n >= 0)
			{
				var result = Unserializer.run(resultAndCode.substr(0, n));
				var code = resultAndCode.substr(n + 1);
				trace("AJAX result:");
				trace(result);
				trace("AJAX code:\n" + code);
				untyped __js__("eval(code)");
				if (callbackFunc != null)
				{
					callbackFunc(result);
				}
			}
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
    
    public static function getDataObjectForSendToServer(componentID:String, method:String, ?params:Array<Dynamic>) : Dynamic
    {
        var sendData : Dynamic = {
			 HAQUERY_POSTBACK : 1
			,HAQUERY_COMPONENT : componentID
			,HAQUERY_METHOD : method
			,HAQUERY_PARAMS : Serializer.run(params)
		};

        var sendedElements = getElemsForSendToServer();
        for (sendElem in sendedElements)
        {
            var nodeName = sendElem.nodeName.toUpperCase();
            if (nodeName == 'INPUT' && sendElem.getAttribute('type').toUpperCase() == "CHECKBOX")
            {
                sendData[untyped sendElem.id] = Reflect.field(sendElem, 'checked') ? '1' : '0';
            }
            else
            if (nodeName == 'INPUT' && sendElem.getAttribute('type').toUpperCase() == "RADIO")
            {
                if (Reflect.field(sendElem, 'checked'))
                {
                    var name = sendElem.getAttribute('name');
                    if (name != null && name != '')
                    {
                        sendData[untyped name] = sendElem.getAttribute('value');
                    }
                }
            }
            else
            {
                sendData[untyped sendElem.id] = new JQuery(sendElem).val();
            }
        }
        
        return sendData;
    }
	
	static function getElemsForSendToServer() : Iterable<HtmlDom>
	{
		var allElemsWithID = new JQuery("[id]").get();
		var elems = Lambda.filter(allElemsWithID, function(elem)
        {
            var elemTag = elem.nodeName.toUpperCase();
            var elemType = elemTag=="INPUT" ? elem.getAttribute('type').toUpperCase() : '';
            return elemTag == "INPUT" && Lambda.has(["TEXT", "PASSWORD", "HIDDEN", "CHECKBOX", "RADIO"], elemType)
				|| elemTag == "TEXTAREA"
				|| elemTag == "SELECT";
		});
		
		return elems;
	}
}
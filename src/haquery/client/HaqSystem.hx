package haquery.client;

import js.Dom.HtmlDom;
import js.Lib;
import jQuery.JQuery;
import haquery.client.HaqComponentManager;
import haquery.client.HaqTemplates;
import haquery.client.HaQuery;

class HaqSystem 
{
    static var elemEventNames : Array<String> = [
		'click', 'change', 'load',
		'mousedown', 'mouseup', 'mousemove',
		'mouseover', 'mouseout', 'mouseenter', 'mouseleave',
		'keypress', 'keydown', 'keyup', 
		'focus', 'focusin', 'focusout',
    ];
	
	public function new() : Void
	{
		var templates = new HaqTemplates(HaqInternals.componentsFolders, HaqInternals.componentsServerHandlers);
		var manager = new HaqComponentManager(templates, HaqInternals.id_tag);
		var page = manager.createPage();
		for (elem in (new JQuery("*[id]")).toArray())
		{
			connectElemEventHandlers(page, templates, untyped elem);
		}
	}

	static function connectElemEventHandlers(page:HaqPage, templates:HaqTemplates, elem:HtmlDom)
    {
        var n : Int = elem.getAttribute('id').lastIndexOf(HaqInternals.DELIMITER);
        var componentID = n > 0 ? elem.getAttribute('id').substr(0, n) : '';
        var elemID = n > 0 ? elem.getAttribute('id').substr(n + 1) : elem.getAttribute('id');
        var component = page.findComponent(componentID);
        if (component == null) return;
        for (eventName in elemEventNames)
        {
            if (Reflect.hasMethod(component, elemID+"_"+eventName)
             || templates.get(component.tag).elemID_serverHandlers!=null
             && templates.get(component.tag).elemID_serverHandlers.get(elemID)!=null
             && templates.get(component.tag).elemID_serverHandlers.get(elemID).indexOf(eventName)!=-1
            ) {
				new JQuery(elem).bind(eventName, null, function(e:js.Dom.Event):Bool { return elemEventHandler(templates, page, elem, e); } );
			}
        }
    }

    static function elemEventHandler(templates:HaqTemplates, page:HaqPage, elem:HtmlDom, e:js.Dom.Event) : Bool
    {
		var n = elem.id.lastIndexOf(HaqInternals.DELIMITER);
        var componentID = n > 0 ? elem.getAttribute('id').substr(0, n) : '';
        var component = page.findComponent(componentID);
		HaQuery.assert(component != null);

		var r = callClientElemEventHandlers(component, elem, e);
		if (!r) return false;
        
		var serverHandlers = component.parent == null 
            ? HaqInternals.pageServerHandlers
            : templates.get(component.tag).elemID_serverHandlers;
        return callServerElemEventHandlers(serverHandlers, component, elem, e);
    }
	
	static function callClientElemEventHandlers(component:HaqComponent, elem:HtmlDom, e:js.Dom.Event) : Bool
	{
		var n = elem.id.lastIndexOf(HaqInternals.DELIMITER);
		var elemID = n > 0 ? elem.id.substr(n + 1) : elem.id;
		var methodName = elemID + "_" + e.type;
		if (Reflect.hasMethod(component, methodName))
		{
			var r = Reflect.callMethod(component, Reflect.field(component, methodName), [e]);
			if (r==false) return false;
		}
		return true;
	}
	
	static function callServerElemEventHandlers(serverHandlers:Hash<Array<String>>, component:HaqComponent, elem:HtmlDom, e:js.Dom.Event) : Bool
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

            for (sendElem in getElemsForSendToServer(component))
            {
                sendData[untyped sendElem.id] = sendElem.nodeName.toUpperCase() == 'INPUT' && sendElem.getAttribute('type').toUpperCase() == "CHECKBOX"
                    ? (Reflect.field(sendElem, 'checked') ? new JQuery(sendElem).val() : '')
                    : new JQuery(sendElem).val();
            }

            JQueryStatic.post(
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
	
	static function getElemsForSendToServer(component:HaqComponent) : Iterable<HtmlDom>
	{
		var idParts : Array<String> = component.fullID.split(HaqInternals.DELIMITER);
		var reStr = '(^[^' + HaqInternals.DELIMITER + ']+$)';
		trace('reStr = ' + reStr);
		for (i in 0...idParts.length)
		{
			var s = '(^' + idParts.slice(0, i + 1).join(HaqInternals.DELIMITER) + HaqInternals.DELIMITER + '[^' + HaqInternals.DELIMITER + ']+$)';
			trace('reStr = ' + s);
			reStr += '|' + s;
		}
		var re : EReg = new EReg(reStr, '');
		
		var jqAllElemsWithID = new JQuery("[id]");
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
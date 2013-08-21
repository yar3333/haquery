package haquery.client;

#if client

import haquery.common.HaqMessageListenerAnswer;
import haquery.common.HaqStorage;
import haxe.Serializer;
import haxe.Unserializer;
import js.Dom;
import js.JQuery;
import haquery.client.Lib;
import haquery.common.HaqDefines;
using stdlib.StringTools;

class HaqServerCallerAjax
{
	var page : HaqPage;
	var url : String;
	
	public function new(page:HaqPage, url:String)
	{
		this.page = page;
		this.url = url;
	}
	
	public function callSharedMethod(componentID:String, method:String, ?params:Array<Dynamic>, ?callb:Dynamic->Void) : Void
	{
		var sendData = getDataObjectForSendToServer(componentID, method, params);
		JQuery.postAjax(url, sendData, function(data:String) : Void
		{ 
			var message : HaqMessageListenerAnswer = Unserializer.run(data);
			switch (message)
			{
				case HaqMessageListenerAnswer.CallSharedServerMethodAnswer(ajaxResponse, result):
					var page = this.page;
					Lib.eval(ajaxResponse);
					if (callb != null)
					{
						callb(result);
					}
				
				default:
					throw "Unexpected server answer (" + message + ").";
			}
		});
	}
	
	
    function getDataObjectForSendToServer(componentID:String, method:String, ?params:Array<Dynamic>) : Dynamic
    {
        var sendData : Dynamic = {
			 HAQUERY_POSTBACK: 1
			,HAQUERY_COMPONENT: componentID
			,HAQUERY_METHOD: method
			,HAQUERY_PARAMS: Serializer.run(params)
			,HAQUERY_STORAGE: Serializer.run(page.storage.getStorageToSend())
		};

        var sendedElements = getElemsForSendToServer();
        for (sendElem in sendedElements)
        {
            var nodeName = sendElem.nodeName.toUpperCase();
            if (nodeName == "INPUT" && getInputType(sendElem) == "CHECKBOX")
            {
                sendData[untyped sendElem.id] = Reflect.field(sendElem, "checked") ? "1" : "0";
            }
            else
            if (nodeName == "INPUT" && getInputType(sendElem) == "RADIO")
            {
                if (Reflect.field(sendElem, "checked"))
                {
                    var name = sendElem.getAttribute("name");
                    if (name != null && name != "")
                    {
                        sendData[untyped name] = sendElem.getAttribute("value");
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
	
	function getElemsForSendToServer() : Iterable<HtmlDom>
	{
		var allElemsWithID = new JQuery("[id]").toArray();
		var elems = Lambda.filter(allElemsWithID, function(elem)
        {
            var elemTag = elem.nodeName.toUpperCase();
            return elemTag == "INPUT" && getInputType(elem) != "FILE"
				|| elemTag == "TEXTAREA"
				|| elemTag == "SELECT";
		});
		
		return elems;
	}
	
	function getInputType(elem:HtmlDom) : String
	{
		var type = elem.getAttribute("type");
		if (type == null || type == "") return "TEXT";
		return type.toUpperCase();
	}
}

#end
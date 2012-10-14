package haquery.client;

import haquery.common.HaqComponentTools;
import haquery.common.HaqMessageListenerAnswer;
import haquery.common.HaqMessageToListener;
import haxe.Serializer;
import haxe.Unserializer;
import js.WebSocket;

class HaqServerCallerWebsocket
{
	var callQueue : Array<{ componentFullID:String, method:String, params:Array<Dynamic> }>;
	var callbacks : Array<Dynamic->Void>;
	var isConnected = false;
	var socket : WebSocket;

	public function new(uri:String, pageKey:String, pageSecret:String) 
	{
		callQueue = [];
		callbacks = [];
		
		WebSocket.WEB_SOCKET_SWF_LOCATION = "/haquery/client/websocket.swf";
		socket = new WebSocket(uri);
		
		socket.onopen = function() 
		{
			socket.send(Serializer.run(HaqMessageToListener.ConnectToPage(pageKey, pageSecret)));
			isConnected = true;
		};
		
		socket.onmessage = function(e)
		{
			var answer : HaqMessageListenerAnswer = Unserializer.run(e.data);
			switch (answer)
			{
				case HaqMessageListenerAnswer.CallSharedServerMethodAnswer(ajaxResponse, result):
					var callb = callbacks.shift();
					Lib.eval(ajaxResponse);
					if (callb != null)
					{
						callb(result);
					}
				
				case HaqMessageListenerAnswer.CallAnotherClientMethod(componentFullID, method, params):
					var component = Lib.page.findComponent(componentFullID);
					component.callSharedClientMethod(method, params, true);
				
				case HaqMessageListenerAnswer.ProcessUncalledServerMethodAnswer(ajaxAnswer):
					Lib.eval(ajaxAnswer);
				
				case HaqMessageListenerAnswer.CallAnotherServerMethodAnswer(result):
					var callb = callbacks.shift();
					if (callb != null)
					{
						callb(result);
					}
			}
		};
		
		socket.onclose = function() 
		{
			isConnected = false;
		};
	}
	
	public function callSharedServerMethod(componentFullID:String, method:String, params:Array<Dynamic>, callb:Dynamic->Void) : Void
	{
		callbacks.push(callb);
		callQueue.push( { componentFullID:componentFullID, method:method, params:params } );
		
		if (isConnected)
		{
			while (callQueue.length > 0)
			{
				var c = callQueue.shift();
				socket.send(Serializer.run(HaqMessageToListener.CallSharedServerMethod(componentFullID, method, params)));
			}
		}
	}
	
	public function callAnotherServerMethod(pageKey:String, componentFullID:String, method:String, params:Array<Dynamic>, callb:Dynamic->Void) : Void
	{
		callbacks.push(callb);
		callQueue.push( { componentFullID:componentFullID, method:method, params:params } );
		
		if (isConnected)
		{
			while (callQueue.length > 0)
			{
				var c = callQueue.shift();
				socket.send(Serializer.run(HaqMessageToListener.CallAnotherServerMethod(pageKey, componentFullID, method, params)));
			}
		}
	}
}
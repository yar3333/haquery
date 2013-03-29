package haquery.client;

#if client

import haquery.common.HaqComponentTools;
import haquery.common.HaqMessageListenerAnswer;
import haquery.common.HaqMessageToListener;
import stdlib.Exception;
import haxe.Serializer;
import haxe.Unserializer;
import js.WebSocket;

class HaqServerCallerWebsocket
{
	var sendQueue : Array<HaqMessageToListener>;
	var recvQueue : Array<{ success:Dynamic->Void, fail:Exception->Void }>;
	var socket : WebSocket;
	var isConnected = false;

	function send(message:HaqMessageToListener)
	{
		socket.send(Serializer.run(message));
	}
	
	function processSendQueue()
	{
		if (isConnected)
		{
			while (sendQueue.length > 0)
			{
				send(sendQueue.shift());
			}
		}
	}
	
	function processRecvQueue(result:CallbackResult)
	{
		var callb = recvQueue.shift();
		switch (result)
		{
			case CallbackResult.Success(ret): if (callb.success != null) callb.success(ret);
			case CallbackResult.Fail(error): if (callb.fail != null) callb.fail(error);
		}
	}
	
	public function new(uri:String, pageKey:String, pageSecret:String) 
	{
		sendQueue = [];
		recvQueue = [];
		
		WebSocket.WEB_SOCKET_SWF_LOCATION = "/haquery/client/websocket.swf";
		socket = new WebSocket(uri);
		
		socket.onopen = function() 
		{
			send(HaqMessageToListener.ConnectToPage(pageKey, pageSecret));
			isConnected = true;
			if (Lib.page.onConnect())
			{
				processSendQueue();					
			}
		};
		
		socket.onmessage = function(e)
		{
			var answer : HaqMessageListenerAnswer = Unserializer.run(e.data);
			switch (answer)
			{
				case HaqMessageListenerAnswer.CallSharedServerMethodAnswer(ajaxResponse, result):
					Lib.eval(ajaxResponse);
					processRecvQueue(result);
				
				case HaqMessageListenerAnswer.CallAnotherClientMethod(componentFullID, method, params):
					var component = Lib.page.findComponent(componentFullID);
					if (component != null)
					{
						try
						{
							component.callClientMethod(method, params, "another");
						}
						catch (e:Dynamic)
						{
							trace(e);
						}
					}
				
				case HaqMessageListenerAnswer.ProcessUncalledServerMethodAnswer(ajaxAnswer):
					try
					{
						Lib.eval(ajaxAnswer);
					}
					catch (e:Dynamic)
					{
						trace(e);
					}
					
				case HaqMessageListenerAnswer.CallAnotherServerMethodAnswer(result):
					processRecvQueue(result);
					
				case HaqMessageListenerAnswer.CallAnotherClientMethodAnswer(result):
					processRecvQueue(result);
			}
		};
		
		socket.onclose = function() 
		{
			isConnected = false;
			Lib.page.onDisconnect();
		};
	}
	
	public function callSharedServerMethod(componentFullID:String, method:String, params:Array<Dynamic>, success:Dynamic->Void, fail:Exception->Void) : Void
	{
		recvQueue.push({ success:success, fail:fail });
		sendQueue.push(HaqMessageToListener.CallSharedServerMethod(componentFullID, method, params));
		processSendQueue();
	}
	
	public function callAnotherServerMethod(pageKey:String, componentFullID:String, method:String, params:Array<Dynamic>, success:Dynamic->Void, fail:Exception->Void) : Void
	{
		recvQueue.push({ success:success, fail:fail });
		sendQueue.push(HaqMessageToListener.CallAnotherServerMethod(pageKey, componentFullID, method, params));
		processSendQueue();
	}
	
	public function callAnotherClientMethod(pageKey:String, componentFullID:String, method:String, params:Array<Dynamic>, success:Void->Void, fail:Exception->Void) : Void
	{
		recvQueue.push({ success:function(_) success(), fail:fail });
		sendQueue.push(HaqMessageToListener.CallAnotherClientMethod(pageKey, componentFullID, method, params));
		processSendQueue();
	}
}

#end
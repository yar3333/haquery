package haquery.client;

import haquery.common.HaqDaemonMessage;
import haxe.Serializer;
import haxe.Unserializer;
import js.WebSocket;

class HaqDaemon 
{
	var callQueue : Array<{ componentFullID:String, method:String, params:Array<Dynamic> }>;
	var callbacks : Array<Dynamic->Void>;
	var isConnected = false;
	var socket : WebSocket;

	public function new(uri:String, pageUuid:String) 
	{
		callQueue = [];
		callbacks = [];
		
		WebSocket.WEB_SOCKET_SWF_LOCATION = "/haquery/client/websocket.swf";
		socket = new WebSocket(uri);
		
		socket.onopen = function() 
		{
			socket.send(Serializer.run(HaqDaemonMessage.ConnectToPage(pageUuid)));
			isConnected = true;
		};
		
		socket.onmessage = function(e)
		{
			var callb = callbacks.shift();
			if (callb != null)
			{
				callb(Unserializer.run(e.data));
			}
		};
		
		socket.onclose = function() 
		{
			isConnected = false;
		};
	}
	
	public function callSharedMethod(componentFullID:String, method:String, params:Array<Dynamic>, callb:Dynamic->Void) : Void
	{
		callbacks.push(callb);
		callQueue.push( { componentFullID:componentFullID, method:method, params:params } );
		
		if (isConnected)
		{
			while (callQueue.length > 0)
			{
				var c = callQueue.shift();
				socket.send(Serializer.run(HaqDaemonMessage.CallSharedMethod(componentFullID, method, params)));
			}
		}
	}
	
}
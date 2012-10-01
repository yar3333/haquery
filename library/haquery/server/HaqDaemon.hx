package haquery.server;

import haxe.Serializer;
import haxe.Unserializer;
import neko.Sys;
import sys.net.WebSocket;

enum HaqDaemonConnection
{
	Server(request:HaqRequest);
	Client(uid:String);
}

class ClientData extends neko.net.WebSocketServerLoop.ClientData
{
	var connection : HaqDaemonConnection;
}

class HaqDaemon
{
	var pages : Hash<HaqPage>;
	var server : neko.net.WebSocketServerLoop<ClientData>;
	
	public function new()
	{
		pages = new Hash<HaqPage>();
		server = new neko.net.WebSocketServerLoop<ClientData>();
		server.processIncomingMessage = processIncomingMessage;
	}
	
	public function run(host:String, port:Int)
	{
		server.run(new sys.net.Host(host), port);
	}
	
	function processIncomingMessage(client:ClientData, text:String)
	{
		var obj = Unserializer.run(text);
		if (Std.is(obj, HaqDaemonConnection))
		{
			switch (cast(obj, HaqDaemonConnection))
			{
				case HaqDaemonConnection.Server(request):
					trace("server");
					var page = Lib.manager.createPage();
					var response = page.process();
					client.ws.send(Serializer.run(response));
					pages.set(Uuid.newUuid(), page);
				
				case HaqDaemonConnection.Client(uid):
					trace("client");
					var page = pages.get(uid);
					var response = page.process();
					client.ws.send(Serializer.run(response));
			}
		}
		else
		{
			// disconnect
		}
	}
	
	public static function requestServer(host:String, port:Int, request:HaqRequest) : HaqResponse
	{
		var ws = WebSocket.connect(host, port, "haquery", hostAndPort.host);
		ws.send(Serializer.run(HaqDaemonConnection.Server(request)));
		return Unserializer.run(ws.recv());
	}
}

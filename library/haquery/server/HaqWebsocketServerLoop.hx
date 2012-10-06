package haquery.server;

import haxe.Serializer;
import haxe.Unserializer;
import haquery.common.HaqDefines;
import haquery.common.HaqMessage;
import neko.net.WebSocketServerLoop;
import sys.net.WebSocket;

class ClientData extends WebSocketServerLoop.ClientData
{
	public var pageUuid : String;
}

class HaqWebsocketServerLoop
{
	var waitedPages : Hash<{ page:HaqPage, created:Date }>;
	var activePages : Hash<{ page:HaqPage, ws:WebSocket }>;
	
	var server : WebSocketServerLoop<ClientData>;
	
	public function new()
	{
		waitedPages = new Hash<{ page:HaqPage, created:Date }>();
		activePages = new Hash<{ page:HaqPage, ws:WebSocket }>();
		
		server = new WebSocketServerLoop<ClientData>(function(socket) return new ClientData(socket));
		server.processIncomingMessage = processIncomingMessage;
	}
	
	public function run(host:String, port:Int)
	{
		server.run(new sys.net.Host(host), port);
	}
	
	function processIncomingMessage(client:ClientData, text:String)
	{
		var obj = Unserializer.run(text);
		if (Std.is(obj, HaqMessage))
		{
			switch (cast(obj, HaqMessage))
			{
				case HaqMessage.MakeRequest(request):
					neko.Lib.println("INCOMING MakeRequest [" + request.pageUuid + "] URI = " + request.uri);
					var route = new HaqRouter(HaqDefines.folders.pages).getRoute(request.params.get("route"));
					var bootstraps = Lib.loadBootstraps(route.path);
					var r = Lib.runPage(request, route, bootstraps);
					waitedPages.set(r.page.pageUuid, { page:r.page, created:Date.now() });
					client.ws.send(Serializer.run(r.response));
				
				case HaqMessage.ConnectToPage(pageUuid):
					neko.Lib.println("INCOMING ConnectToPage [" + pageUuid + "]");
					client.pageUuid = pageUuid;
					var p = waitedPages.get(pageUuid);
					waitedPages.remove(pageUuid);
					activePages.set(pageUuid, { page:p.page, ws:client.ws });
				
				case HaqMessage.CallSharedMethod(componentFullID, method, params):
					neko.Lib.println("INCOMING CallSharedMethod [" + client.pageUuid + "] method = " + componentFullID + "." + method);
					var p = activePages.get(client.pageUuid);
					p.page.prepareNewPostback();
					var response : HaqResponse = p.page.generateResponseOnPostback(componentFullID, method, params);
					client.ws.send(response.content);
			}
		}
		else
		{
			// disconnect
		}
	}
}

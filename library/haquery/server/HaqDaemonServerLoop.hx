package haquery.server;

import haxe.Serializer;
import haxe.Unserializer;
import haquery.common.HaqDefines;
import haquery.common.HaqDaemonMessage;
import neko.net.WebSocketServerLoop;

class ClientData extends WebSocketServerLoop.ClientData
{
	var connection : HaqDaemonMessage;
}

class HaqDaemonServerLoop
{
	var pages : Hash<HaqPage>;
	var server : WebSocketServerLoop<ClientData>;
	
	public function new()
	{
		pages = new Hash<HaqPage>();
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
		if (Std.is(obj, HaqDaemonMessage))
		{
			switch (cast(obj, HaqDaemonMessage))
			{
				case HaqDaemonMessage.Server(request):
					trace("server");
					var route = new HaqRouter(HaqDefines.folders.pages).getRoute(request.params.get("route"));
					var bootstraps = Lib.loadBootstraps(route.path);
					var r = Lib.runPage(request, route, bootstraps);
					pages.set(r.page.pageUuid, r.page);
					client.ws.send(Serializer.run(r.response));
				
				case HaqDaemonMessage.Client(pageUuid, componentFullID, method, params):
					trace("client");
					var page = pages.get(pageUuid);
					var response = page.generateResponseByCallSharedMethod(componentFullID, method, params);
					client.ws.send(Serializer.run(response));
			}
		}
		else
		{
			// disconnect
		}
	}
}

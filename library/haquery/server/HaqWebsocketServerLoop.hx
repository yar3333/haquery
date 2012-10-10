package haquery.server;

#if php
private typedef NativeLib = php.Lib;
#elseif neko
private typedef NativeLib = neko.Lib;
#end

import haquery.server.db.HaqDb;
import haxe.PosInfos;
import haxe.Serializer;
import haxe.Unserializer;
import haquery.common.HaqDefines;
import haquery.common.HaqMessage;
import neko.net.WebSocketServerLoop;
import neko.vm.Gc;
import sys.net.WebSocket;

class ClientData extends WebSocketServerLoop.ClientData
{
	public var pageUuid : String;
}

class HaqWebsocketServerLoop
{
	static inline var removeWaitedPageInterval = 60;
	
	var name : String;
	var compilationDate : Date;
	
	var waitedPages : Hash<{ page:HaqPage, config:HaqConfig, db:HaqDb, created:Float }>;
	var activePages : Hash<{ page:HaqPage, config:HaqConfig, db:HaqDb, ws:WebSocket }>;
	
	var server : WebSocketServerLoop<ClientData>;
	
	public function new(name:String)
	{
		this.name = name;
		this.compilationDate = Lib.getCompilationDate();
		
		this.waitedPages = new Hash<{ page:HaqPage, config:HaqConfig, db:HaqDb, created:Float }>();
		this.activePages = new Hash<{ page:HaqPage, config:HaqConfig, db:HaqDb, ws:WebSocket }>();
		
		this.server = new WebSocketServerLoop<ClientData>(function(socket) return new ClientData(socket));
		
		this.server.processIncomingMessage = processIncomingMessage;
		
		this.server.processDisconnect = function(client:ClientData)
		{
			if (client.pageUuid != null)
			{
				activePages.remove(client.pageUuid);
			}
		};
		
		this.server.processUpdate = function()
		{
			var now = Date.now().getTime() / 1000;
			
			for (pageUuid in waitedPages.keys())
			{
				if (now - waitedPages.get(pageUuid).created > removeWaitedPageInterval)
				{
					waitedPages.remove(pageUuid);
				}
			}
			
			var nowCompilationDate : Date = compilationDate; 
			try { nowCompilationDate = Lib.getCompilationDate(); } catch (e:Dynamic) {}
			
			if (nowCompilationDate.getTime() != compilationDate.getTime())
			{
				NativeLib.print("AUTORESTART ");
				server.stop();
				var p = new sys.io.Process("neko", [ "index.n", "haquery-listener", "run", name ]);
				NativeLib.println("PID = " + p.getPid());
				Sys.exit(0);
			}
		};
	}
	
	public function run(host:String, port:Int)
	{
		trace("HAQUERY LISTENER start at " + host + ":" + port);
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
					waitedPages.set(r.page.pageUuid, { page:r.page, config:r.config, db:r.db, created:Date.now().getTime() / 1000 });
					client.ws.send(Serializer.run(r.response));
				
				case HaqMessage.ConnectToPage(pageUuid):
					neko.Lib.println("INCOMING ConnectToPage [" + pageUuid + "]");
					client.pageUuid = pageUuid;
					var p = waitedPages.get(pageUuid);
					waitedPages.remove(pageUuid);
					activePages.set(pageUuid, { page:p.page, config:p.config, db:p.db, ws:client.ws });
				
				case HaqMessage.CallSharedMethod(componentFullID, method, params):
					neko.Lib.println("INCOMING CallSharedMethod [" + client.pageUuid + "] method = " + componentFullID + "." + method);
					var p = activePages.get(client.pageUuid);
					Lib.pageContext(p.page, p.page.clientIP, p.config, p.db, function()
					{
						p.page.prepareNewPostback();
						var response = p.page.generateResponseOnPostback(componentFullID, method, params);
						client.ws.send(response.content);
					});
				
				case HaqMessage.Status:
					var s = "pages active: " + Lambda.count(activePages) + "\n"
						  + "pages waiting queue: " + Lambda.count(waitedPages) + "\n"
						  + "memory heap: " + Math.round(Gc.stats().heap / 1024 / 1024) + " MB\n";
					client.ws.send(s);
				
				case HaqMessage.Stop:
					Sys.exit(0);
			}
		}
		else
		{
			server.closeConnection(client.ws.socket);
		}
	}
}

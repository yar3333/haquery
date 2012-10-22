package haquery.server;

import haquery.Exception;
import haquery.server.db.HaqDb;
import haxe.PosInfos;
import haxe.Serializer;
import haxe.Unserializer;
import haquery.common.HaqDefines;
import haquery.common.HaqMessageToListener;
import haquery.common.HaqMessageListenerAnswer;
import neko.net.WebSocketServerLoop;
import neko.vm.Gc;
import sys.net.WebSocket;

private typedef WaitedPage = { page:HaqPage, config:HaqConfig, db:HaqDb, created:Float }

private class ClientData extends WebSocketServerLoop.ClientData
{
	public var pageKey : String;
	
	public function send(a:HaqMessageListenerAnswer)
	{
		ws.send(Serializer.run(a));
	}
}

class HaqWebsocketServerLoop
{
	static inline var removeWaitedPageInterval = 60;
	
	var name : String;
	var compilationDate : Date;
	
	var waitedPages : Hash<WaitedPage>;
	public var pages(default, null) : Hash<HaqConnectedPage>;
	
	var server : WebSocketServerLoop<ClientData>;
	
	public function new(name:String)
	{
		this.name = name;
		this.compilationDate = Lib.getCompilationDate();
		
		this.waitedPages = new Hash<WaitedPage>();
		this.pages = new Hash<HaqConnectedPage>();
		
		this.server = new WebSocketServerLoop<ClientData>(function(socket) return new ClientData(socket));
		
		this.server.processIncomingMessage = processIncomingMessage;
		
		this.server.processDisconnect = function(client:ClientData)
		{
			if (client.pageKey != null)
			{
				var p = pages.get(client.pageKey);
				if (p != null)
				{
					if (p.page != null)
					{
						p.page.onDisconnect();
					}
					pages.remove(client.pageKey);
				}
			}
		};
		
		this.server.processUpdate = function()
		{
			var now = Date.now().getTime() / 1000;
			
			for (pageKey in waitedPages.keys())
			{
				if (now - waitedPages.get(pageKey).created > removeWaitedPageInterval)
				{
					waitedPages.remove(pageKey);
				}
			}
			
			var nowCompilationDate : Date = compilationDate; 
			try { nowCompilationDate = Lib.getCompilationDate(); } catch (e:Dynamic) {}
			
			if (nowCompilationDate.getTime() != compilationDate.getTime())
			{
				trace("AUTORESTART");
				server.stop();
				Sys.sleep(5);
				var p = new sys.io.Process("neko", [ "index.n", "haquery-listener", "run", name ]);
				trace("PID = " + p.getPid());
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
		if (Std.is(obj, HaqMessageToListener))
		{
			switch (cast(obj, HaqMessageToListener))
			{
				case HaqMessageToListener.MakeRequest(request):
					trace("INCOMING MakeRequest [" + request.pageKey + "] URI = " + request.uri);
					var route = new HaqRouter(HaqDefines.folders.pages).getRoute(request.params.get("route"));
					var bootstraps = Lib.loadBootstraps(route.path);
					var r = Lib.runPage(request, route, bootstraps);
					if (!request.isPostback)
					{
						waitedPages.set(r.page.pageKey, { page:r.page, config:r.config, db:r.db, created:Date.now().getTime() / 1000 } );
					}
					client.send(HaqMessageListenerAnswer.MakeRequestAnswer(r.response));
				
				case HaqMessageToListener.ConnectToPage(pageKey, pageSecret):
					trace("INCOMING ConnectToPage [" + pageKey + "]");
					client.pageKey = pageKey;
					var p = waitedPages.get(pageKey);
					waitedPages.remove(pageKey);
					
					if (p != null && p.page.pageSecret == pageSecret && p.page.onConnect())
					{
						var r = false;
						Lib.pageContext(p.page, p.page.clientIP, p.config, p.db, function()
						{
							try
							{
								r = p.page.onConnect();
							}
							catch (e:Dynamic)
							{
								Exception.trace(e);
							}
						});
						if (r)
						{
							pages.set(pageKey, new HaqConnectedPage(p.page, p.config, p.db, client.ws));
						}
					}
					else
					{
						server.closeConnection(client.ws.socket);
					}
				
				case HaqMessageToListener.CallSharedServerMethod(componentFullID, method, params):
					trace("INCOMING CallSharedServerMethod [" + client.pageKey + "] method = " + componentFullID + "." + method);
					var p = pages.get(client.pageKey);
					var response = p.callSharedServerMethod(componentFullID, method, params);
					client.send(HaqMessageListenerAnswer.CallSharedServerMethodAnswer(response.ajaxResponse, CallbackResult.Success(response.result)));
				
				case HaqMessageToListener.CallAnotherClientMethod(pageKey, componentFullID, method, params):
					trace("INCOMING CallAnotherClientMethod [" + client.pageKey + "] pageKey = " + pageKey + ", method = " + componentFullID + "." + method);
					var p = pages.get(pageKey);
					try
					{
						p.callAnotherClientMethod(componentFullID, method, params);
						client.send(HaqMessageListenerAnswer.CallAnotherClientMethodAnswer(CallbackResult.Success(null)));
					}
					catch (e:Dynamic)
					{
						Exception.trace(e);
						client.send(HaqMessageListenerAnswer.CallAnotherClientMethodAnswer(CallbackResult.Fail(Exception.wrap(e))));
					}
				
				case HaqMessageToListener.CallAnotherServerMethod(pageKey, componentFullID, method, params):
					trace("INCOMING CallAnotherServerMethod [" + client.pageKey + "] pageKey = " + pageKey + ", method = " + componentFullID + "." + method);
					var p = pages.get(pageKey);
					try
					{
						var result = p.callAnotherServerMethod(componentFullID, method, params);
						client.send(HaqMessageListenerAnswer.CallAnotherServerMethodAnswer(CallbackResult.Success(result)));
					}
					catch (e:Dynamic)
					{
						Exception.trace(e);
						client.send(HaqMessageListenerAnswer.CallAnotherServerMethodAnswer(CallbackResult.Fail(Exception.wrap(e))));
					}
				
				case HaqMessageToListener.Status:
					var s = "connected pages: " + Lambda.count(pages) + "\n"
						  + "waited pages: " + Lambda.count(waitedPages) + "\n"
						  + "memory heap: " + IntTools.groupDigits(Math.round(Gc.stats().heap / 1024), " ") + " KB\n";
					client.ws.send(s);
				
				case HaqMessageToListener.Stop:
					trace("HAQUERY LISTENER stop");
					Sys.exit(0);
			}
		}
		else
		{
			server.closeConnection(client.ws.socket);
		}
	}
}
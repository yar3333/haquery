package haquery.server;

#if server

import haquery.Exception;
import haxe.PosInfos;
import haxe.Serializer;
import haxe.Unserializer;
import haquery.common.HaqDefines;
import haquery.common.HaqMessageToListener;
import haquery.common.HaqMessageListenerAnswer;
import neko.net.WebSocketThreadServer;
import neko.vm.Gc;
import neko.vm.Thread;
import sys.net.WebSocket;
import models.server.Page;

private typedef WaitedPage = { page:Page, created:Float }

class HaqWebsocketThreadServer
{
	static inline var removeWaitedPageInterval = 60;
	
	var name : String;
	var compilationDate : Date;
	
	var waitedPages : SafeHash<WaitedPage>;
	public var connectedPages(default, null) : SafeHash<HaqConnectedPage>;
	
	var server : WebSocketThreadServer;
	
	public function new(name:String)
	{
		this.name = name;
		this.compilationDate = Lib.getCompilationDate();
		
		this.waitedPages = new SafeHash<WaitedPage>();
		this.connectedPages = new SafeHash<HaqConnectedPage>();
		
		this.server = new WebSocketThreadServer();
		
		this.server.processIncomingConnection = processIncomingConnection;
	}
	
	public function run(host:String, port:Int)
	{
		trace("HAQUERY LISTENER start at " + host + ":" + port);
		
		Thread.create(function()
		{
			while (true)
			{
				Sys.sleep(1);
				
				var now = Date.now().getTime() / 1000;
				
				for (pageKey in waitedPages.keys())
				{
					try
					{
						if (now - waitedPages.get(pageKey).created > removeWaitedPageInterval)
						{
							waitedPages.remove(pageKey);
						}
					}
					catch (e:Dynamic) {}
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
			}
		});
		
		server.run(host, port);
	}
	
	function processIncomingConnection(ws:WebSocket)
	{
		var connected : HaqConnectedPage = null;
		
		var text : String; 
		while ((text = ws.recv()) != null)
		{
			var obj = Unserializer.run(text);
			if (Std.is(obj, HaqMessageToListener))
			{
				switch (cast(obj, HaqMessageToListener))
				{
					case HaqMessageToListener.MakeRequest(request):
						trace("INCOMING MakeRequest [" + request.pageKey + "] URI = " + request.uri);
						var route = new HaqRouter(HaqDefines.folders.pages, Lib.manager).getRoute(request.params.get("route"));
						var bootstraps = Lib.loadBootstraps(route.path, request.config);
						var r = Lib.runPage(request, route, bootstraps);
						if (!request.isPostback)
						{
							waitedPages.set(r.page.pageKey, { page:r.page, created:Date.now().getTime() / 1000 } );
						}
						ws.send(Serializer.run(HaqMessageListenerAnswer.MakeRequestAnswer(r.response)));
					
					case HaqMessageToListener.ConnectToPage(pageKey, pageSecret):
						trace("INCOMING ConnectToPage [" + pageKey + "]");
						var waited = waitedPages.get(pageKey);
						waitedPages.remove(pageKey);
						
						if (waited != null && waited.page.pageSecret == pageSecret)
						{
							connected = new HaqConnectedPage(waited.page, ws);
							var response = connected.callServerMethod("", "onConnect", []);
							ws.send(Serializer.run(HaqMessageListenerAnswer.ProcessUncalledServerMethodAnswer(response.ajaxResponse)));
							if (response.result != false)
							{
								connectedPages.set(pageKey, connected);
							}
							else
							{
								break;
							}
						}
						else
						{
							break;
						}
					
					case HaqMessageToListener.CallSharedServerMethod(componentFullID, method, params):
						trace("INCOMING CallSharedServerMethod [" + connected.pageKey + "] method = " + componentFullID + "." + method);
						var response = connected.callSharedServerMethod(componentFullID, method, params);
						connected.send(HaqMessageListenerAnswer.CallSharedServerMethodAnswer(response.ajaxResponse, CallbackResult.Success(response.result)));
					
					case HaqMessageToListener.CallAnotherClientMethod(pageKey, componentFullID, method, params):
						trace("INCOMING CallAnotherClientMethod [" + connected.pageKey + "] pageKey = " + pageKey + ", method = " + componentFullID + "." + method);
						var anotherConnected = connectedPages.get(pageKey);
						try
						{
							anotherConnected.callAnotherClientMethod(componentFullID, method, params);
							connected.send(HaqMessageListenerAnswer.CallAnotherClientMethodAnswer(CallbackResult.Success(null)));
						}
						catch (e:Dynamic)
						{
							Exception.trace(e);
							connected.send(HaqMessageListenerAnswer.CallAnotherClientMethodAnswer(CallbackResult.Fail(Exception.wrap(e))));
						}
					
					case HaqMessageToListener.CallAnotherServerMethod(pageKey, componentFullID, method, params):
						trace("INCOMING CallAnotherServerMethod [" + connected.pageKey + "] pageKey = " + pageKey + ", method = " + componentFullID + "." + method);
						var p = connectedPages.get(pageKey);
						try
						{
							var result = p.callAnotherServerMethod(componentFullID, method, params);
							connected.send(HaqMessageListenerAnswer.CallAnotherServerMethodAnswer(CallbackResult.Success(result)));
						}
						catch (e:Dynamic)
						{
							Exception.trace(e);
							connected.send(HaqMessageListenerAnswer.CallAnotherServerMethodAnswer(CallbackResult.Fail(Exception.wrap(e))));
						}
					
					case HaqMessageToListener.Status:
						var s = "connected pages: " + connectedPages.length + "\n"
							  + "waited pages: " + waitedPages.length + "\n"
							  + "memory heap: " + groupDigits(Math.round(Gc.stats().heap / 1024), " ") + " KB\n";
						ws.send(s);
					
					case HaqMessageToListener.Stop:
						trace("HAQUERY LISTENER stop");
						Sys.exit(0);
				}
			}
			else
			{
				break;
			}
		}
		
		if (connected != null)
		{
			disconnect(connected.pageKey);
		}
		
		try if (ws != null) ws.socket.close() catch (e:Dynamic) {}
	}
	
	public function disconnect(pageKey:String)
	{
		if (pageKey != null)
		{
			var p = connectedPages.get(pageKey);
			if (p != null)
			{
				connectedPages.remove(pageKey);
				p.disconnect();
			}
		}
	}
	
	/**
	* Groups the digits in the input number by using a thousands separator.<br/>
	* E.g. the number 1024 is converted to the string '1.024'.
	* @param thousandsSeparator a character to use as a thousands separator. The default value is ".".
	*/
	static function groupDigits(x:Int, ?thousandsSeparator = '.') : String
	{
		var n : Float = x;
		var c = 0;
		while (n > 1)
		{
			n /= 10;
			c++;
		}
		c = cast c / 3;
		var source = Std.string(x);
		if (c == 0)
			return source;
		else
		{
			var target = '';

			var i = 0;
			var j = source.length - 1;
			while (j >= 0)
			{
				if (i == 3)
				{
					target = source.charAt(j--) + thousandsSeparator + target;
					i = 0;
					c--;
				}
				else
					target = source.charAt(j--) + target;
				i++;
			}
			return target;
		}
	}
}

#end
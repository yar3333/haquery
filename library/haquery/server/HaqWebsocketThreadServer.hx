package haquery.server;

#if server

import haquery.Exception;
import haquery.server.db.HaqDb;
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
	
	var waitedPages : Hash<WaitedPage>;
	public var pages(default, null) : Hash<HaqConnectedPage>;
	
	var server : WebSocketThreadServer;
	
	public function new(name:String)
	{
		this.name = name;
		this.compilationDate = Lib.getCompilationDate();
		
		this.waitedPages = new Hash<WaitedPage>();
		this.pages = new Hash<HaqConnectedPage>();
		
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
			}
		});
		
		server.run(host, port);
	}
	
	function processIncomingConnection(ws:WebSocket)
	{
		var pageKey : String = null;
		
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
					
					case HaqMessageToListener.ConnectToPage(pageKeyParam, pageSecret):
						trace("INCOMING ConnectToPage [" + pageKeyParam + "]");
						pageKey = pageKeyParam;
						var p = waitedPages.get(pageKey);
						waitedPages.remove(pageKey);
						
						if (p != null && p.page.pageSecret == pageSecret)
						{
							var p = new HaqConnectedPage(p.page, ws);
							var response = p.callServerMethod("", "onConnect", []);
							ws.send(Serializer.run(HaqMessageListenerAnswer.ProcessUncalledServerMethodAnswer(response.ajaxResponse)));
							if (response.result != false)
							{
								pages.set(pageKey, p);
							}
							else
							{
								close(ws, pageKey);
							}
						}
						else
						{
							close(ws, pageKey);
						}
					
					case HaqMessageToListener.CallSharedServerMethod(componentFullID, method, params):
						trace("INCOMING CallSharedServerMethod [" + pageKey + "] method = " + componentFullID + "." + method);
						var p = pages.get(pageKey);
						var response = p.callSharedServerMethod(componentFullID, method, params);
						ws.send(Serializer.run(HaqMessageListenerAnswer.CallSharedServerMethodAnswer(response.ajaxResponse, CallbackResult.Success(response.result))));
					
					case HaqMessageToListener.CallAnotherClientMethod(pageKey, componentFullID, method, params):
						trace("INCOMING CallAnotherClientMethod [" + pageKey + "] pageKey = " + pageKey + ", method = " + componentFullID + "." + method);
						var p = pages.get(pageKey);
						try
						{
							p.callAnotherClientMethod(componentFullID, method, params);
							ws.send(Serializer.run(HaqMessageListenerAnswer.CallAnotherClientMethodAnswer(CallbackResult.Success(null))));
						}
						catch (e:Dynamic)
						{
							Exception.trace(e);
							ws.send(Serializer.run(HaqMessageListenerAnswer.CallAnotherClientMethodAnswer(CallbackResult.Fail(Exception.wrap(e)))));
						}
					
					case HaqMessageToListener.CallAnotherServerMethod(pageKey, componentFullID, method, params):
						trace("INCOMING CallAnotherServerMethod [" + pageKey + "] pageKey = " + pageKey + ", method = " + componentFullID + "." + method);
						var p = pages.get(pageKey);
						try
						{
							var result = p.callAnotherServerMethod(componentFullID, method, params);
							ws.send(Serializer.run(HaqMessageListenerAnswer.CallAnotherServerMethodAnswer(CallbackResult.Success(result))));
						}
						catch (e:Dynamic)
						{
							Exception.trace(e);
							ws.send(Serializer.run(HaqMessageListenerAnswer.CallAnotherServerMethodAnswer(CallbackResult.Fail(Exception.wrap(e)))));
						}
					
					case HaqMessageToListener.Status:
						var s = "connected pages: " + Lambda.count(pages) + "\n"
							  + "waited pages: " + Lambda.count(waitedPages) + "\n"
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
		
		close(ws, pageKey);
	}
	
	public function disconnectPage(pageKey:String)
	{
		var p = pages.get(pageKey);
		if (p != null)
		{
			try p.ws.socket.close() catch (e:Dynamic) {}
			
			if (p.page != null)
			{
				Lib.pageContext(p.page, p.page.config, p.page.clientIP, function()
				{
					p.page.onDisconnect();
				});
				
				if (p.page.pageKey != null)
				{
					pages.remove(p.page.pageKey);
				}
			}
			
		}
	}
	
	function close(ws:WebSocket, pageKey:String)
	{
		try ws.socket.close() catch (e:Dynamic) {}
	
		if (pageKey != null)
		{
			disconnectPage(pageKey);
		}
	}
	
	/**
	* Groups the digits in the input number by using a thousands separator.<br/>
	* E.g. the number 1024 is converted to the string '1.024'.
	* @param thousandsSeparator a character to use as a thousands separator. The default value is ".".
	*/
	static function groupDigits(x:Int, ?thousandsSeparator = '.'):String
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
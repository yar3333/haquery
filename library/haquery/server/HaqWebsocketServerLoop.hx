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
	
	public function answer(a:HaqMessageListenerAnswer)
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
					client.answer(HaqMessageListenerAnswer.MakeRequestAnswer(r.response));
				
				case HaqMessageToListener.ConnectToPage(pageKey, pageSecret):
					trace("INCOMING ConnectToPage [" + pageKey + "]");
					client.pageKey = pageKey;
					var p = waitedPages.get(pageKey);
					waitedPages.remove(pageKey);
					if (p != null && p.page.pageSecret == pageSecret && p.page.onConnect())
					{
						pages.set(pageKey, new HaqConnectedPage(p.page, p.config, p.db, client.ws));
					}
					else
					{
						server.closeConnection(client.ws.socket);
					}
				
				case HaqMessageToListener.CallSharedServerMethod(componentFullID, method, params):
					trace("INCOMING CallSharedServerMethod [" + client.pageKey + "] method = " + componentFullID + "." + method);
					var p = pages.get(client.pageKey);
					var content = p.callSharedServerMethod(componentFullID, method, params);
					client.answer(HaqMessageListenerAnswer.CallSharedServerMethodAnswer(content));
				
				case HaqMessageToListener.CallAnotherClientMethod(pageKey, componentFullID, method, params):
					trace("INCOMING CallAnotherClientMethod [" + client.pageKey + "] pageKey = " + pageKey + ", method = " + componentFullID + "." + method);
					var p = pages.get(pageKey);
					p.callAnotherClientMethod(componentFullID, method, params);
				
				case HaqMessageToListener.CallAnotherServerMethod(pageKey, componentFullID, method, params):
					trace("INCOMING CallAnotherServerMethod [" + client.pageKey + "] pageKey = " + pageKey + ", method = " + componentFullID + "." + method);
					var p = pages.get(pageKey);
					var content = p.callAnotherServerMethod(componentFullID, method, params);
					client.answer(HaqMessageListenerAnswer.ProcessUncalledServerMethodAnswer(content));
				
				case HaqMessageToListener.Status:
					var s = "connected pages: " + Lambda.count(pages) + "\n"
						  + "waited pages: " + Lambda.count(waitedPages) + "\n"
						  + "memory heap: " + groupDigits(Math.round(Gc.stats().heap / 1024), " ") + " KB\n";
					client.ws.send(s);
				
				case HaqMessageToListener.Stop:
					Sys.exit(0);
			}
		}
		else
		{
			server.closeConnection(client.ws.socket);
		}
	}
	
	/**
	* Groups the digits in the input number by using a thousands separator.<br/>
	* E.g. the number 1024 is converted to the string '1.024'.
	* @param thousandsSeparator a character to use as a thousands separator. The default value is ".".
	*/
	public static function groupDigits(x:Int, ?thousandsSeparator = '.'):String
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
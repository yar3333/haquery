package haquery.server;

#if server

import stdlib.Exception;
import haxe.Serializer;
import haxe.Unserializer;
import haquery.common.HaqMessageToListener;
import haquery.common.HaqMessageListenerAnswer;
import neko.net.WebSocketServerLoop;
import neko.vm.Gc;

private class ClientData extends WebSocketServerLoop.ClientData
{
	public var pageKey : String;
	
	public function send(a:HaqMessageListenerAnswer)
	{
		ws.send(Serializer.run(a));
	}
}

class HaqExternalServer
{
	static inline var removeWaitedPageInterval = 60;
	
	var name : String;
	var compilationDate : Date;
	var server : WebSocketServerLoop<ClientData>;
	
	var waitedPages : SafeHash<HaqWaitedPage>;
	public var connectedPages(default, null) : SafeHash<HaqConnectedPage>;
	
	public function new(name:String, waitedPages:SafeHash<HaqWaitedPage>)
	{
		this.name = name;
		this.compilationDate = Lib.getCompilationDate();
		this.waitedPages = waitedPages;
		this.connectedPages = new SafeHash<HaqConnectedPage>();
		this.server = new WebSocketServerLoop<ClientData>(function(socket) return new ClientData(socket));
		
		this.server.processIncomingMessage = processIncomingMessage;
		
		this.server.processDisconnect = function(client:ClientData)
		{
			if (client.pageKey != null)
			{
				var p = connectedPages.get(client.pageKey);
				if (p != null)
				{
					p.disconnect();
					connectedPages.remove(client.pageKey);
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
				case HaqMessageToListener.ConnectToPage(pageKey, pageSecret):
					trace("INCOMING ConnectToPage [" + pageKey + "]");
					client.pageKey = pageKey;
					var p = waitedPages.get(pageKey);
					waitedPages.remove(pageKey);
					
					if (p != null && p.page.pageSecret == pageSecret)
					{
						var p = new HaqConnectedPage(p.page, client.ws);
						var response = p.callServerMethod("", "onConnect", []);
						client.send(HaqMessageListenerAnswer.ProcessUncalledServerMethodAnswer(response.ajaxResponse));
						if (response.result != false)
						{
							connectedPages.set(pageKey, p);
						}
						else
						{
							server.closeConnection(client.ws.socket);
						}
					}
					else
					{
						server.closeConnection(client.ws.socket);
					}
				
				case HaqMessageToListener.CallSharedServerMethod(componentFullID, method, params):
					trace("INCOMING CallSharedServerMethod [" + client.pageKey + "] method = " + componentFullID + "." + method);
					var p = connectedPages.get(client.pageKey);
					var response = p.callSharedServerMethod(componentFullID, method, params);
					client.send(HaqMessageListenerAnswer.CallSharedServerMethodAnswer(response.ajaxResponse, CallbackResult.Success(response.result)));
				
				case HaqMessageToListener.CallAnotherClientMethod(pageKey, componentFullID, method, params):
					trace("INCOMING CallAnotherClientMethod [" + client.pageKey + "] pageKey = " + pageKey + ", method = " + componentFullID + "." + method);
					var p = connectedPages.get(pageKey);
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
					var p = connectedPages.get(pageKey);
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
				
				default:
					trace("EXTERNAL: incoming message '" + obj + "' not supported.");
			}
		}
		else
		{
			server.closeConnection(client.ws.socket);
		}
	}
	
	public function disconnect(pageKey:String)
	{
		var p = connectedPages.get(pageKey);
		if (p != null)
		{
			p.disconnect();
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
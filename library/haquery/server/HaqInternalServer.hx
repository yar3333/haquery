package haquery.server;

#if server

import haquery.Exception;
import haxe.Serializer;
import haxe.Unserializer;
import haquery.common.HaqDefines;
import haquery.common.HaqMessageToListener;
import haquery.common.HaqMessageListenerAnswer;
import neko.net.WebSocketThreadServer;
import neko.vm.Gc;
import sys.net.WebSocket;

class HaqInternalServer
{
	var name : String;
	var server : WebSocketThreadServer;
	
	public var waitedPages(default, null) : SafeHash<HaqWaitedPage>;
	
	public function new(name:String)
	{
		this.name = name;
		this.waitedPages = new SafeHash<HaqWaitedPage>();
		this.server = new WebSocketThreadServer();
		this.server.processIncomingConnection = processIncomingConnection;
	}
	
	public function run(host:String, port:Int)
	{
		trace("HAQUERY LISTENER start at " + host + ":" + port);
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
						if (!r.page.disableListener && !request.isPostback)
						{
							r.page.db.makePooled();
							waitedPages.set(r.page.pageKey, { page:r.page, created:Date.now().getTime() / 1000 } );
						}
						ws.send(Serializer.run(HaqMessageListenerAnswer.MakeRequestAnswer(r.response)));
					
					case HaqMessageToListener.Status:
						var s = //"connected pages: " + connectedPages.length + "\n"
							  /*+*/ "waited pages: " + waitedPages.length + "\n"
							  + "memory heap: " + groupDigits(Math.round(Gc.stats().heap / 1024), " ") + " KB\n";
						ws.send(s);
					
					case HaqMessageToListener.Stop:
						trace("HAQUERY LISTENER stop");
						Sys.exit(0);
				
					default:
						trace("INTERNAL: incoming message '" + obj + "' not supported.");
				}
			}
			else
			{
				break;
			}
		}
		
		try if (ws != null) ws.socket.close() catch (e:Dynamic) {}
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
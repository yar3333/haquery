package haquery.server;

#if neko

import haxe.Serializer;
import haxe.Unserializer;
import neko.Sys;
import sys.io.Process;
import sys.net.WebSocket;
import haquery.common.HaqMessageToListener;
import haquery.common.HaqMessageListenerAnswer;

class HaqWebsocketListener
{
	public var name(default, null) : String;
	public var host(default, null) : String;
	public var port(default, null) : Int;
	public var autorun(default, null) : Bool;
	
	var server : HaqWebsocketThreadServer;
	public var pages(getPages, null) : SafeHash<HaqConnectedPage>;
	
	public function new(name:String, host:String, port:Int, autorun:Bool) 
	{
		this.name = name;
		this.host = host;
		this.port = port;
		this.autorun = autorun;
	}
	
	public function getUri()
	{
		return "ws://" + host + ":" + port;
	}
	
	public function makeRequest(request:HaqRequest) : HaqResponse
	{
		trace("makeRequest to " + host + ":" + port);
		
		var ws : WebSocket;
		try { ws = WebSocket.connect(host, port, "haquery", host); } 
		catch (e:Dynamic)
		{
			if (autorun)
			{
				trace("Try to autostart...");
				var p = start();
				trace(p != null ? "SUCCESS PID = " + p.getPid() : "FAIL");
				Sys.sleep(1);
				ws = WebSocket.connect(host, port, "haquery", host);
			}
			else
			{
				return null;
			}
		}
		trace("Send request object to server...");
		ws.send(Serializer.run(HaqMessageToListener.MakeRequest(request)));
		trace("Read response...");
		var r = ws.recv();
		trace("Response received.");
		
		var answer = cast(Unserializer.run(r), HaqMessageListenerAnswer);
		
		switch (answer)
		{
			case HaqMessageListenerAnswer.MakeRequestAnswer(response):
				return response;
			
			default:
				throw "Unexpected listener answer: " + answer;
				
		}
		
		return null;
	}
	
	public function status() : String
	{
		try
		{
			var ws = WebSocket.connect(host, port, "haquery", host);
			ws.send(Serializer.run(HaqMessageToListener.Status));
			var r = ws.recv();
			ws.socket.close();
			return r;
		}
		catch (e:Dynamic)
		{
			return null;
		}
	}
	
	public function start() : Process
	{
		return new Process("neko", [ "index.n", "haquery-listener", "run", name ]);
	}
	
	public function stop()
	{
		try
		{
			var ws = WebSocket.connect(host, port, "haquery", host);
			ws.send(Serializer.run(HaqMessageToListener.Stop));
			ws.socket.close();
		}
		catch (e:Dynamic)
		{
		}
	}
	
	public function run()
	{
		server = new HaqWebsocketThreadServer(name);
		server.run(host, port);
	}
	
	function getPages() : SafeHash<HaqConnectedPage>
	{
		return server != null ? server.connectedPages : null;
	}
	
	public function disconnectPage(pageKey:String)
	{
		if (server != null)
		{
			server.disconnect(pageKey);
		}
	}
}

#end
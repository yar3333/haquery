package haquery.server;

#if neko

import haxe.Serializer;
import haxe.Unserializer;
import neko.Sys;
import neko.vm.Thread;
import sys.io.Process;
import sys.net.WebSocket;
import haquery.common.HaqMessageToListener;
import haquery.common.HaqMessageListenerAnswer;

class HaqListener
{
	public var name(default, null) : String;
	public var host(default, null) : String;
	public var internalPort(default, null) : Int;
	public var externalPort(default, null) : Int;
	public var autorun(default, null) : Bool;
	
	var internalServer : HaqInternalServer;
	var externalServer : HaqExternalServer;
	
	public var pages(getPages, null) : SafeHash<HaqConnectedPage>;
	
	public function new(name:String, host:String, internalPort:Int, externalPort:Int, autorun:Bool) 
	{
		this.name = name;
		this.host = host;
		this.internalPort = internalPort;
		this.externalPort = externalPort;
		this.autorun = autorun;
	}
	
	public function getUri()
	{
		return "ws://" + host + ":" + externalPort;
	}
	
	public function makeRequest(request:HaqRequest) : HaqResponse
	{
		trace("makeRequest to " + host + ":" + internalPort);
		
		var ws : WebSocket;
		try { ws = WebSocket.connect(host, internalPort, "haquery", host); } 
		catch (e:Dynamic)
		{
			if (autorun)
			{
				trace("Try to autostart...");
				var p = start();
				trace(p != null ? "SUCCESS PID = " + p.getPid() : "FAIL");
				Sys.sleep(1);
				ws = WebSocket.connect(host, internalPort, "haquery", host);
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
			var ws = WebSocket.connect(host, internalPort, "haquery", host);
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
			var ws = WebSocket.connect(host, internalPort, "haquery", host);
			ws.send(Serializer.run(HaqMessageToListener.Stop));
			ws.socket.close();
		}
		catch (e:Dynamic)
		{
		}
	}
	
	public function run()
	{
		internalServer = new HaqInternalServer(name);
		externalServer = new HaqExternalServer(name, internalServer.waitedPages);
		
		Thread.create(function()
		{
			externalServer.run(host, externalPort);
		});
		
		internalServer.run(host, internalPort);
	}
	
	function getPages() : SafeHash<HaqConnectedPage>
	{
		return externalServer != null ? externalServer.connectedPages : null;
	}
	
	public function disconnectPage(pageKey:String)
	{
		if (externalServer != null)
		{
			externalServer.disconnect(pageKey);
		}
	}
}

#end
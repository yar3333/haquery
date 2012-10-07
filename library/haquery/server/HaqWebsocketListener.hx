package haquery.server;

import haxe.Serializer;
import haxe.Unserializer;
import sys.net.WebSocket;
import haquery.common.HaqMessage;

class HaqWebsocketListener
{
	public var name(default, null) : String;
	public var host(default, null) : String;
	public var port(default, null) : Int;
	public var autorun(default, null) : Bool;
	
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
		trace("requestServer to " + host + ":" + port);
		var ws = WebSocket.connect(host, port, "haquery", host);
		trace("Send request object to server...");
		ws.send(Serializer.run(HaqMessage.MakeRequest(request)));
		trace("Wait response...");
		var r = ws.recv();
		trace("Response received");
		return Unserializer.run(r);
	}
	
	public function status() : String
	{
		try
		{
			var ws = WebSocket.connect(host, port, "haquery", host);
			ws.send(Serializer.run(HaqMessage.Status));
			var r = ws.recv();
			ws.socket.close();
			return r;
		}
		catch (e:Dynamic)
		{
			return null;
		}
	}
	
	public function stop()
	{
		try
		{
			var ws = WebSocket.connect(host, port, "haquery", host);
			ws.send(Serializer.run(HaqMessage.Stop));
			ws.socket.close();
		}
		catch (e:Dynamic)
		{
		}
	}
	
	public function run()
	{
		var server = new HaqWebsocketServerLoop(name);
		server.run(host, port);
	}
}
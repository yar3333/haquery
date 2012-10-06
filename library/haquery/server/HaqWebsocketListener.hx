package haquery.server;

import haxe.Serializer;
import haxe.Unserializer;
import sys.net.WebSocket;
import haquery.common.HaqMessage;

class HaqWebsocketListener
{
	var host : String;
	var port : Int;
	var autorun : Bool;
	
	public function new(host:String, port:Int, autorun:Bool) 
	{
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
	
	public function run()
	{
		var server = new HaqWebsocketServerLoop();
		server.run(host, port);
	}
}
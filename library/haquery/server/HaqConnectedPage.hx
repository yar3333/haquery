package haquery.server;

import haquery.common.HaqMessageListenerAnswer;
import haquery.server.db.HaqDb;
import haquery.common.HaqComponentTools;
import haxe.Serializer;
import sys.net.WebSocket;

class HaqConnectedPage
{
	public var page(default, null) : HaqPage;
	public var config(default, null) : HaqConfig;
	public var db(default, null) : HaqDb;
	public var ws(default, null) : WebSocket;
	
	public function new(page:HaqPage, config:HaqConfig, db:HaqDb, ws:WebSocket)
	{
		this.page = page;
		this.config = config;
		this.db = db;
		this.ws = ws;
	}
	
	public function callServerMethod(componentFullID:String, method:String, params:Array<Dynamic>) : Dynamic
	{
		var r : Dynamic;
		Lib.pageContext(page, page.clientIP, config, db, function()
		{
			var component = page.findComponent(componentFullID);
			r = component.callAnotherServerMethod(method, params);
		});
		return r;
	}
	
	public function callClientMethod(componentFullID:String, method:String, params:Array<Dynamic>) : Void
	{
		ws.send(Serializer.run(HaqMessageListenerAnswer.CallAnotherClientMethod(componentFullID, method, params)));
	}
}

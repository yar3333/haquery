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
	
	public function callSharedServerMethod(componentFullID:String, method:String, params:Array<Dynamic>) : HaqResponse
	{
		var r : Dynamic = null;
		Lib.pageContext(page, page.clientIP, config, db, function()
		{
			r = page.generateResponseOnPostback(componentFullID, method, params, false);
		});
		return r;
	}
	
	public function callAnotherServerMethod(componentFullID:String, method:String, params:Array<Dynamic>) : Dynamic
	{
		var r = null;
		Lib.pageContext(page, page.clientIP, config, db, function()
		{
			var response = page.generateResponseOnPostback(componentFullID, method, params, true);
			send(HaqMessageListenerAnswer.ProcessUncalledServerMethodAnswer(response.ajaxResponse));
			r = response.result;
		});
		return r;
	}
	
	public function callAnotherClientMethod(componentFullID:String, method:String, params:Array<Dynamic>) : Void
	{
		trace("send to [ " + page.pageKey + " ] CallAnotherClientMethod(" + componentFullID + ", " + method + ")");
		send(HaqMessageListenerAnswer.CallAnotherClientMethod(componentFullID, method, params));
	}
	
	public function send(a:HaqMessageListenerAnswer)
	{
		ws.send(Serializer.run(a));
	}
}

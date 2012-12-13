package haquery.server;

#if server

import haquery.common.HaqMessageListenerAnswer;
import haquery.server.db.HaqDb;
import haquery.common.HaqComponentTools;
import haxe.Serializer;
import sys.net.WebSocket;

class HaqConnectedPage
{
	public var page(default, null) : HaqPage;
	public var db(default, null) : HaqDb;
	public var ws(default, null) : WebSocket;
	
	public function new(page:HaqPage, db:HaqDb, ws:WebSocket)
	{
		this.page = page;
		this.db = db;
		this.ws = ws;
	}
	
	public function callServerMethod(componentFullID:String, method:String, params:Array<Dynamic>) : HaqResponse
	{
		var r : Dynamic = null;
		Lib.pageContext(page, page.config, page.clientIP, db, function()
		{
			r = page.generateResponseOnPostback(componentFullID, method, params);
		});
		return r;
	}
	
	public function callSharedServerMethod(componentFullID:String, method:String, params:Array<Dynamic>) : HaqResponse
	{
		var r : Dynamic = null;
		Lib.pageContext(page, page.config, page.clientIP, db, function()
		{
			r = page.generateResponseOnPostback(componentFullID, method, params, "shared");
		});
		return r;
	}
	
	public function callAnotherServerMethod(componentFullID:String, method:String, params:Array<Dynamic>) : Dynamic
	{
		var r = null;
		Lib.pageContext(page, page.config, page.clientIP, db, function()
		{
			var response = page.generateResponseOnPostback(componentFullID, method, params, "another");
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

#end
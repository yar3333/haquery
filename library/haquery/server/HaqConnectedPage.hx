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
	
	public function callSharedServerMethod(componentFullID:String, method:String, params:Array<Dynamic>) : String
	{
		var content = "";
		Lib.pageContext(page, page.clientIP, config, db, function()
		{
			try
			{
				page.prepareNewPostback();
				content = page.generateResponseOnPostback(componentFullID, method, params, false).content;
			}
			catch (e:Dynamic)
			{
				Exception.trace(e);
				content = e;
			}
		});
		return content;
	}
	
	public function callAnotherServerMethod(componentFullID:String, method:String, params:Array<Dynamic>) : Dynamic
	{
		var content = "";
		Lib.pageContext(page, page.clientIP, config, db, function()
		{
			try
			{
				page.prepareNewPostback();
				content = page.generateResponseOnPostback(componentFullID, method, params, true).content;
			}
			catch (e:Dynamic)
			{
				Exception.trace(e);
				content = e;
			}
		});
		return content;
	}
	
	public function callAnotherClientMethod(componentFullID:String, method:String, params:Array<Dynamic>) : Void
	{
		ws.send(Serializer.run(HaqMessageListenerAnswer.CallAnotherClientMethod(componentFullID, method, params)));
	}
}

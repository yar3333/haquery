package haquery.server;

#if server

import haquery.common.HaqMessageListenerAnswer;
import haquery.common.HaqComponentTools;
import haquery.Exception;
import haxe.Serializer;
import models.server.Page;
import neko.vm.Mutex;
import sys.net.WebSocket;

class HaqConnectedPage
{
	public var pageKey(default, null) : String;
	
	var page(default, null) : Page;
	var ws(default, null) : WebSocket;
	var mutex(default, null) : Mutex;
	
	public function new(page:Page, ws:WebSocket)
	{
		pageKey = page.pageKey;
		
		this.page = page;
		this.ws = ws;
		this.mutex = new Mutex();
	}
	
	public function callServerMethod(componentFullID:String, method:String, params:Array<Dynamic>) : HaqResponse
	{
		var r : HaqResponse = null;
		mutex.acquire();
		r = page.generateResponseOnPostback(componentFullID, method, params);
		mutex.release();
		return r;
	}
	
	public function callSharedServerMethod(componentFullID:String, method:String, params:Array<Dynamic>) : HaqResponse
	{
		var r : HaqResponse = null;
		mutex.acquire();
		r = page.generateResponseOnPostback(componentFullID, method, params, "shared");
		mutex.release();
		return r;
	}
	
	public function callAnotherServerMethod(componentFullID:String, method:String, params:Array<Dynamic>) : Dynamic
	{
		var r : Dynamic = null;
		mutex.acquire();
		var response = page.generateResponseOnPostback(componentFullID, method, params, "another");
		send(HaqMessageListenerAnswer.ProcessUncalledServerMethodAnswer(response.ajaxResponse));
		r = response.result;
		mutex.release();
		return r;
	}
	
	public function callAnotherClientMethod(componentFullID:String, method:String, params:Array<Dynamic>) : Void
	{
		trace("send to [ " + page.pageKey + " ] CallAnotherClientMethod(" + componentFullID + ", " + method + ")");
		send(HaqMessageListenerAnswer.CallAnotherClientMethod(componentFullID, method, params));
	}
	
	public function send(a:HaqMessageListenerAnswer)
	{
		mutex.acquire();
		ws.send(Serializer.run(a));
		mutex.release();
	}
	
	public function disconnect()
	{
		mutex.acquire();
		try page.onDisconnect() catch (e:Dynamic) Exception.trace(e);
		try ws.socket.close() catch(e:Dynamic) {}
		mutex.release();
	}
}

#end
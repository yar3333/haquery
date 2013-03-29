package haquery.server;

#if server

import haquery.common.HaqMessageListenerAnswer;
import orm.Db;
import haxe.htmlparser.HtmlNodeElement;
import haxe.htmlparser.HtmlNodeText;
import haquery.common.HaqDefines;
import haquery.common.HaqComponentTools;
import haquery.server.HaqComponent;
import haquery.server.HaqCookie;
import stdlib.FileSystem;
import stdlib.Exception;
import haquery.server.Lib;
import haxe.Json;
import haxe.Serializer;
using stdlib.StringTools;

class HaqPage extends HaqComponent
{
    /**
     * Last unexist URL part will be placed to this var. 
     * For example, if your request "http://site.com/news/123"
     * then pageID will be "123".
     */
    public var pageID(default, null) : String;
    
	/**
     * false => rendering html, true => calling server event handler.
     */
    public var isPostback(default, null) : Bool;

	public var params(default, null) : Hash<String>;
	
	public var cookie(default, null) : HaqCookie;
	
	public var requestHeaders(default, null) : HaqRequestHeaders;
	
	public var clientIP(default, null) : String;
	
	public var uri(default, null) : String;
	
	public var host(default, null) : String;
	
	public var queryString(default, null) : String;
	
	public var config(default, null) : HaqConfig;
	
	public var db(default, null) : Db;
	
	/**
	 * Default value is "text/html; charset=utf-8".
	 */
    public var contentType = "text/html; charset=utf-8";
    
    /**
     * Disable system CSS and JS inserts to your HTML pages.
     */
	public var disableSystemHtmlInserts = false;
	
    /**
     * Disable waiting websocket connection from client. Use for optimization on special pages.
     */
	public var disableListener = false;
	
	/**
	 * Js code to response.
	 */
	var ajaxResponse(default, null) : String;
	
	/**
	 * Http status code to return.
	 */
	public var statusCode = 200;
	
	public var responseHeaders(default, null) : HaqResponseHeaders;
	
	/**
	 * Page's unique id for server pages list.
	 */
	public var pageKey(default, null) : String;
	
	/**
	 * Page's secret keyword for security when connectiong to server.
	 */
	public var pageSecret(default, null) : String;
	
	public var session(default, null) : HaqSession;
	
	public function new()
	{
		super();
		ajaxResponse = "";
		responseHeaders = new HaqResponseHeaders();
		session = new HaqSession(this);
	}
	
	public function generateResponseOnRender() : HaqResponse
	{
		return {
			responseHeaders:responseHeaders, 
			statusCode:statusCode, 
			cookie:cookie.response, 
			content:render(), 
			ajaxResponse:null, 
			result:null
		};
	}

	public function generateResponseOnPostback(componentFullID:String, method:String, params:Array<Dynamic>, ?meta:String) : HaqResponse
	{
		var component = findComponent(componentFullID);
		if (component != null)
		{
			isPostback = true;
			responseHeaders = new HaqResponseHeaders();
			cookie.response.reset();
			ajaxResponse = "";
			
			var result = component.callServerMethod(method, params, meta);
			
			if (statusCode != 301 && statusCode != 307)
			{
				responseHeaders.set("Content-Type", "text/plain; charset=utf-8");
			}
			
			return {
				responseHeaders:responseHeaders, 
				statusCode:statusCode, 
				cookie:cookie.response, 
				content:null, 
				ajaxResponse:ajaxResponse, 
				result:result
			};
		}
		else
		{
			throw new Exception("Component id = '" + componentFullID + "' not found.");
			return null;
		}
	}
	
	override public function render() : String 
	{
        Lib.profiler.begin("preRender");
		forEachComponent('preRender');
        Lib.profiler.end();
		
		var isRedirected = statusCode == 301 || statusCode == 307;
		
		if (!isRedirected)
		{
			responseHeaders.set('Content-Type', contentType);
			
			if (!disableSystemHtmlInserts)
			{
				var tagIDs = HaqComponentTools.fillTagIDs(this, new Hash<Array<String>>());
				
				insertStyles(manager.getRegisteredStyles());
				insertScripts(manager.getRegisteredScripts());
				insertInitBlock(
					  "<script>\n"
					+ "if(typeof haquery=='undefined') alert('haquery.js must be loaded!');\n"
					+ "haquery.client.HaqInternals.tagIDs = {\n"
					+ Lambda.map({ iterator:tagIDs.keys }, function(tag) return "'" + tag + "':" + Json.stringify(tagIDs.get(tag))).join(",\n")
					+ "\n};\n"
					+ "haquery.client.HaqInternals.sharedStorage = haquery.client.HaqInternals.unserialize('" + Serializer.run(manager.sharedStorage) + "');\n"
					#if neko
					+ "haquery.client.HaqInternals.listener = " + (!disableListener && HaqSystem.listener != null ? "'" + HaqSystem.listener.getUri() + "'" : "null") + ";\n"
					+ "haquery.client.HaqInternals.pageKey = '" + pageKey + "';\n"
					+ "haquery.client.HaqInternals.pageSecret = '" + pageSecret + "';\n"
					#end
					+ "haquery.client.Lib.run('" + fullTag + "');\n"
					+ ajaxResponse
					+ "</script>"
				);
			}
			
			return super.render();
		}
		else
		{
			return "";
		}
	}
    
    function insertStyles(links:Array<String>)
    {
        var text = Lambda.map(links, function(path) return getStyleLink(path)).join("\n");
        var heads = doc.find(">html>head");
        if (heads.length > 0)
        {
            var head : HtmlNodeElement = heads[0];
            var child : HtmlNodeElement = null;
            if (head.children.length > 0)
            {
                child = head.children[0];
                while (child != null && child.name != "link" && (child.getAttribute("rel") != "stylesheet" || child.getAttribute("type") != "text/css"))
                {
                    child = child.getNextSiblingElement();
                }
            }
            head.addChild(new HtmlNodeText(text + "\n"), child);
        }
        else
        {
            doc.addChild(new HtmlNodeText(text + "\n"));
        }
    }
    
    function insertScripts(links:Array<String>)
    {
        var text = Lambda.map(links, function(path) return getScriptLink(path)).join("\n");
        var heads = doc.find(">html>head");
        if (heads.length > 0)
        {
            var head : HtmlNodeElement = heads[0];
            var child : HtmlNodeElement = null;
            if (head.children.length > 0)
            {
                child = head.children[0];
                while (child != null && child.name != "script")
                {
                    child = child.getNextSiblingElement();
                }
            }
            head.addChild(new HtmlNodeText(text + "\n"), child);
        }
        else
        {
            doc.addChild(new HtmlNodeText(text + "\n"));
        }
    }
    
    function insertInitBlock(text:String)
    {
        var bodyes = doc.find(">html>body");
        if (bodyes.length > 0)
        {
            var body = bodyes[0];
            body.addChild(new HtmlNodeText("\n        " + text.replace('\n', '\n        ') + '\n    '));
        }
        else
        {
            doc.addChild(new HtmlNodeText("\n" + text + '\n'));
        }
    }
    
    function getScriptLink(url:String) : String
    {
		if (url == null) return "";
		
		if (url.startsWith("<")) return url;
		
		if (!url.startsWith("http://") && !url.startsWith("/"))
		{
			url += "?" + FileSystem.stat(url).mtime.getTime() / 1000;
			url = "/" + url;
		}
		
		return "<script src='" + url + "'></script>";
    }
    
	function getStyleLink(url:String) : String
    {
		if (url == null) return "";
		
		if (url.startsWith("<")) return url;
		
		if (!url.startsWith("http://") && !url.startsWith("/"))
		{
			url += "?" + FileSystem.stat(url).mtime.getTime() / 1000;
			url = '/' + url;
		}
		
        return "<link rel='stylesheet' type='text/css' href='" + url + "' />";
    }
	
    public function redirect(url:String) : Void
    {
        if (isPostback)
		{
			addAjaxResponse("haquery.client.Lib.page.redirect('" + url.addcslashes() + "');");
		}
        else
		{
			statusCode = 302; // Moved Temporarily
			responseHeaders.set("Location", url);
		}
    }

	public function reload() : Void
	{
        if (isPostback)
		{
			addAjaxResponse("window.location.reload(true);");
		}
        else
		{
			redirect(uri);
		}
	}
	
	public inline function addAjaxResponse(jsCode:String) 
	{
		ajaxResponse += jsCode + "\n";
	}
	
	/**
	 * Overload to specify code on client to server websocket connection.
	 * Use to security checks or something else.
	 * You can return false to force disconnect.
	 */
	public function onConnect() : Bool return true
	
	/**
	 * Overload to specify code on client to server websocket closing.
	 */
	public function onDisconnect() {}
}

#end
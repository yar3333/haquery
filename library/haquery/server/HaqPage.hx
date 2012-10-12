package haquery.server;

import haquery.server.db.HaqDb;
import haxe.htmlparser.HtmlNodeElement;
import haxe.htmlparser.HtmlNodeText;
import haquery.common.HaqDefines;
import haquery.server.HaqComponent;
import haquery.server.HaqCookie;
import haquery.server.FileSystem;
import haquery.server.Lib;
import haxe.Json;
import haxe.Serializer;
using haquery.StringTools;

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
	
	public var uploadedFiles(default, null) : Hash<HaqUploadedFile>;
	
	public var clientIP(default, null) : String;
	
	public var uri(default, null) : String;
	
	public var host(default, null) : String;
	
	public var queryString(default, null) : String;
	
	/**
	 * Default value is "text/html; charset=utf-8".
	 */
    public var contentType = "text/html; charset=utf-8";
    
    /**
     * Disable special CSS and JS inserts to your HTML pages.
     */
	public var disableSystemHtmlInserts : Bool;
	
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
	
	public function new()
	{
		super();
		ajaxResponse = "";
		responseHeaders = new HaqResponseHeaders();
	}
	
	public function generateResponseOnRender() : HaqResponse
	{
		var content = render();
		
		return {
			  responseHeaders : responseHeaders
			, statusCode : statusCode
			, cookie : cookie.response
			, content : content
		};
	}

	public function prepareNewPostback() : Void
	{
		isPostback = true;
		responseHeaders = new HaqResponseHeaders();
		cookie.response.reset();
		ajaxResponse = "";
	}
	
	public function generateResponseOnPostback(componentFullID:String, method:String, params:Array<Dynamic>) : HaqResponse
	{
		var component = findComponent(componentFullID);
		if (component != null)
		{
			var result = HaqComponentTools.callMethod(component, method, params);
			//trace("HAQUERY FINISH");
			
			var content = ""; 
			if (statusCode != 301 && statusCode != 307)
			{
				responseHeaders.set("Content-Type", "text/plain; charset=utf-8");
				content = "HAQUERY_OK" + Serializer.run(result) + "\n" + ajaxResponse;
			}
			
			return {
				  responseHeaders : responseHeaders
				, statusCode : statusCode
				, cookie : cookie.response
				, content : content
			};
		}
		else
		{
			throw new Exception("Component id = '" + componentFullID + "' not found.");
			return null;
		}
	}
	
	override function render() : String 
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
				insertScripts([ 'haquery/client/jquery.js', HaqDefines.haqueryClientFilePath ].concat(manager.getRegisteredScripts()));
				insertInitBlock(
					  "<script>\n"
					+ "if(typeof haquery=='undefined') alert('" + HaqDefines.haqueryClientFilePath + " must be loaded!');\n"
					+ "haquery.client.HaqInternals.tagIDs = haquery.Std.hash({\n"
					+ Lambda.map({ iterator:tagIDs.keys }, function(tag) return "'" + tag + "':" + Json.stringify(tagIDs.get(tag))).join(",\n")
					+ "\n});\n"
					+ "haquery.client.HaqInternals.sharedStorage = haquery.client.HaqInternals.unserialize('" + Serializer.run(manager.sharedStorage) + "');\n"
					+ "haquery.client.HaqInternals.listener = '" + (HaqSystem.listener != null ? HaqSystem.listener.getUri() : "") + "';\n"
					+ "haquery.client.HaqInternals.pageKey = '" + pageKey + "';\n"
					+ "haquery.client.HaqInternals.pageSecret = '" + pageSecret + "';\n"
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
			addAjaxResponse("page.redirect('" + url.addcslashes() + "');");
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
	public function onConnect(connectedPages:Hash<HaqConnectedPage>) : Bool return true
	
	/**
	 * Overload to specify code on client to server websocket closing.
	 */
	public function onDisconnect() {}
}

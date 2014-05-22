package haquery.server;

#if server

import haquery.common.Generated;
import haquery.common.HaqStorage;
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
using Lambda;

@:allow(haquery.server)
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

	public var params(default, null) : Map<String,String>;
	
	public var cookie(default, null) : HaqCookie;
	
	public var requestHeaders(default, null) : HaqRequestHeaders;
	
	public var clientIP(default, null) : String;
	
	public var uri(default, null) : String;
	
	public var host(default, null) : String;
	
	public var queryString(default, null) : String;
	
	public var config(default, null) : HaqConfig;
	
	/**
	 * Default value is "text/html; charset=utf-8".
	 */
    public var contentType = "text/html; charset=utf-8";
    
    /**
     * Disable system CSS and JS inserts to your HTML pages.
     */
	public var disableSystemHtmlInserts = false;
	
	/**
	 * Disable inserting "<script src='jquery.js'>", "<script src='haquery.js'>" and "<link href='haquery.css'>" tags into your page's html.
	 */
	public var disableSystemScriptsAndStylesRegistering = false;
	
	/**
	 * Js code to response.
	 */
	#if !fullCompletion @:noCompletion #end
	var ajaxResponse(default, null) : String;
	
	/**
	 * Http status code to return.
	 */
	public var statusCode = 200;
	
	public var responseHeaders(default, null) : HaqResponseHeaders;
	
	public var session(default, null) : HaqSession;
	
    public var storage(default, null) : HaqStorage;
	
	#if !fullCompletion @:noCompletion #end
	var registeredStyles(default, null) : Array<String>;
	
	#if !fullCompletion @:noCompletion #end
	var registeredScripts(default, null) : Array<String>;
	
	public function new()
	{
		super();
		ajaxResponse = "";
		responseHeaders = new HaqResponseHeaders();
		session = new HaqSession(this);
		registeredStyles = [];
		registeredScripts = [];
	}
	
	#if !fullCompletion @:noCompletion #end
	public function generateResponseOnRender() : HaqResponse
	{
		var content : String;
		
		Lib.profiler.begin("generateResponseOnRender");
		content = renderCached();
		Lib.profiler.end();
		
		return {
			responseHeaders: responseHeaders, 
			statusCode: statusCode, 
			cookie: cookie.response, 
			content: content, 
			ajaxResponse: null, 
			result: null
		};
	}

	#if !fullCompletion @:noCompletion #end
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
	
	#if !fullCompletion @:noCompletion #end
	override public function renderCached() : String
	{
		if (statusCode == 301 || statusCode == 307) return "";
		return super.renderCached();
	}
	
	#if !fullCompletion @:noCompletion #end
	override public function renderDirect() : String 
	{
        prepareSystemHolders();
		var r = super.renderDirect();
		r = fillSystemHolders(r);
		responseHeaders.set("Content-Type", contentType);
		return r;
	}
	
	#if !fullCompletion @:noCompletion #end
	function prepareSystemHolders()
	{
		var heads = doc.find(">html>head");
        if (heads.length > 0)
        {
			var head : HtmlNodeElement = heads[0];
			
			var childCss : HtmlNodeElement = null;
			if (head.children.length > 0)
			{
				childCss = head.children[0];
				while (childCss != null && !(childCss.name == "link" && (childCss.getAttribute("rel") == "stylesheet" || childCss.getAttribute("type") == "text/css")))
				{
					childCss = childCss.getNextSiblingElement();
				}
			}
			head.addChild(new HtmlNodeText("{HAQUERY_CSS}"), childCss);
			
			var childJs : HtmlNodeElement = null;
			if (head.children.length > 0)
			{
				childJs = head.children[0];
				while (childJs != null && childJs.name != "script")
				{
					childJs = childJs.getNextSiblingElement();
				}
			}
			head.addChild(new HtmlNodeText("{HAQUERY_JS}"), childJs);
        }
        else
        {
            doc.addChild(new HtmlNodeText("{HAQUERY_CSS}"), doc.nodes.length > 0 ? doc.nodes[0] : null);
			
            var childJs : HtmlNodeElement = null;
            if (doc.children.length > 0)
            {
                childJs = doc.children[0];
                while (childJs != null && childJs.name == "link"  && (childJs.getAttribute("rel") == "stylesheet" || childJs.getAttribute("type") == "text/css"))
                {
                    childJs = childJs.getNextSiblingElement();
                }
            }
            doc.addChild(new HtmlNodeText("{HAQUERY_JS}"), childJs);
        }
		
        var bodyes = doc.find(">html>body");
        if (bodyes.length > 0)
        {
            var body = bodyes[0];
            body.addChild(new HtmlNodeText("{HAQUERY_INIT}"));
        }
        else
        {
            doc.addChild(new HtmlNodeText("{HAQUERY_INIT}"));
        }
	}
    
	#if !fullCompletion @:noCompletion #end
	function fillSystemHolders(r:String) : String
	{
		Lib.profiler.begin("fillSystemHolders");
		
		if (!disableSystemHtmlInserts)
		{
			var tagIDs = HaqComponentTools.fillTagIDs(this, new Map<String,Array<String>>());
			
			var systemStyles = [];
			if (!disableSystemScriptsAndStylesRegistering)
			{
				systemStyles.push("haquery/client/haquery.css");
			}
			r = r.replace("{HAQUERY_CSS}", systemStyles.concat(registeredStyles).map(function(path) return getStyleLink(path)).join("\n") + "\n");
			
			var systemScripts = [];
			if (!disableSystemScriptsAndStylesRegistering)
			{
				systemScripts.push("haquery/client/jquery.js");
				systemScripts.push("haquery/client/haquery.js");
			}
			r = r.replace("{HAQUERY_JS}", systemScripts.concat(registeredScripts).map(function(path) return getScriptLink(path)).join("\n") + "\n");
			
			var initBlock = 
				  "\n<script>\n"
				+ "if(typeof haquery=='undefined') alert('haquery.js must be loaded!');\n"
				+ "haquery.client.HaqInternals.setTagIDs({\n"
				+ Lambda.map({ iterator:tagIDs.keys }, function(tag) return "'" + tag + "':" + Json.stringify(tagIDs.get(tag))).join(",\n")
				+ "\n});\n"
				+ "haquery.client.HaqInternals.storage = haquery.client.HaqInternals.unserialize('" + Serializer.run(storage.getStorageToSend()) + "');\n"
				+ "haquery.client.Lib.run('" + fullTag + "');\n"
				+ ajaxResponse
				+ "</script>\n";
			r = r.replace("{HAQUERY_INIT}", initBlock);
		}
		else
		{
			r = r.replace("{HAQUERY_CSS}", "");
			r = r.replace("{HAQUERY_JS}", "");
			r = r.replace("{HAQUERY_INIT}", "");
		}
		
		Lib.profiler.end();
		
		return r;
	}
	
	#if !fullCompletion @:noCompletion #end
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
                while (child != null && !(child.name == "link" && (child.getAttribute("rel") == "stylesheet" || child.getAttribute("type") == "text/css")))
                {
                    child = child.getNextSiblingElement();
                }
            }
            head.addChild(new HtmlNodeText(text + "\n"), child);
        }
        else
        {
            doc.addChild(new HtmlNodeText(text + "\n"), doc.nodes.length > 0 ? doc.nodes[0] : null);
        }
    }
    
	#if !fullCompletion @:noCompletion #end
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
            var child : HtmlNodeElement = null;
            if (doc.children.length > 0)
            {
                child = doc.children[0];
                while (child != null && child.name == "link"  && (child.getAttribute("rel") == "stylesheet" || child.getAttribute("type") == "text/css"))
                {
                    child = child.getNextSiblingElement();
                }
            }
            doc.addChild(new HtmlNodeText(text + "\n"), child);
        }
    }
    
	#if !fullCompletion @:noCompletion #end
    function getScriptLink(url:String) : String
    {
		if (url == null) return "";
		
		if (url.startsWith("<")) return url;
		
		if (!url.startsWith("http://") && !url.startsWith("/"))
		{
			if (FileSystem.exists(url))
			{
				url += "?" + FileSystem.stat(url).mtime.getTime() / 1000;
			}
			else
			{
				trace("HAQUERY WARNING File '" + url + "' does not exists.");
			}
			url = Generated.staticUrlPrefix + "/" + url;
		}
		
		return "<script src='" + url + "'></script>";
    }
    
	#if !fullCompletion @:noCompletion #end
	function getStyleLink(url:String) : String
    {
		if (url == null) return "";
		
		if (url.startsWith("<")) return url;
		
		if (!url.startsWith("http://") && !url.startsWith("/"))
		{
			if (FileSystem.exists(url))
			{
				url += "?" + FileSystem.stat(url).mtime.getTime() / 1000;
			}
			else
			{
				trace("HAQUERY WARNING File '" + url + "' does not exists.");
			}
			url = Generated.staticUrlPrefix + "/" + url;
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
	
	#if !fullCompletion @:noCompletion #end
	public inline function addAjaxResponse(jsCode:String) 
	{
		ajaxResponse += jsCode + "\n";
	}
	
	/**
	 * Called by HaQuery after request. Override to clear resources.
	 */  
	function dispose() : Void {}
}

#end
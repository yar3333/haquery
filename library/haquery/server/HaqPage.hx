package haquery.server;

import haxe.htmlparser.HtmlNodeElement;
import haxe.htmlparser.HtmlNodeText;
import haquery.common.HaqDefines;
import haquery.server.HaqComponent;
import haquery.server.HaqCookie;
import haquery.server.FileSystem;
import haquery.server.Lib;
using haquery.StringTools;

#if php
import php.Web;
#elseif neko
import neko.Web;
#end

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
	
	public var ajaxResponse(default, null) : String;
	
	public var statusCode : Int = 0;
	
	public var responseHeaders(default, null) : HaqResponseHeaders;
	
	public function new()
	{
		super();
		ajaxResponse = "";
	}
	
	public function process() : HaqResponse
	{
		if (!isPostback)
		{
			var content = render();
			
			var isRedirected = statusCode == 301 || statusCode == 307;
			
			if (!isRedirected)
			{
				responseHeaders.set('Content-Type', contentType);
			}
			else
			{
				content = "";
			}
			
			return {
				  responseHeaders : responseHeaders
				, statusCode : statusCode
				, cookie : cookie
				, content : content
			};
		}
		else
		{
			forEachComponent('preEventHandlers');
			var componentID = params.get('HAQUERY_COMPONENT');
			var component = findComponent(componentID);
			if (component != null)
			{
				var result = HaqComponentTools.callMethod(component, params.get('HAQUERY_METHOD'), Unserializer.run(params.get('HAQUERY_PARAMS')));
				//trace("HAQUERY FINISH");
				
				var content = "HAQUERY_OK" + Serializer.run(result) + "\n" + ajaxResponse;
				
				var isRedirected = statusCode == 301 || statusCode == 307;				
				
				if (!isRedirected)
				{
					responseHeaders.set("Content-Type", "text/plain; charset=utf-8");
				}
				else
				{
					content = "";
				}
				
				return {
					  responseHeaders : responseHeaders
					, statusCode : statusCode
					, cookie : cookie
					, content : content
				};
			}
			else
			{
				throw new Exception("Component id = '" + componentID + "' not found.");
				return null;
			}
		}
	}
	
	override function render() : String 
	{
        Lib.profiler.begin("preRender");
		forEachComponent('preRender');
        Lib.profiler.end();
		
		if (!disableSystemHtmlInserts)
		{
			insertStyles(manager.getRegisteredStyles());
			insertScripts([ 'haquery/client/jquery.js', HaqDefines.haqueryClientFilePath ].concat(manager.getRegisteredScripts()));
			insertInitBlock(
				  "<script>\n"
				+ "    if(typeof haquery=='undefined') alert('" + HaqDefines.haqueryClientFilePath + " must be loaded!');\n"
				+ "    " + manager.getDynamicClientCode(this).replace('\n', '\n    ') + '\n'
				+ "</script>"
			);
		}
		
		return super.render();
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
			returnCode = 302; // Moved Temporarily
			headers.set("Location", url);
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
}

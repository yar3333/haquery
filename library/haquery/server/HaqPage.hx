package haquery.server;

import haxe.htmlparser.HtmlNodeElement;
import haxe.htmlparser.HtmlNodeText;
import haquery.common.HaqDefines;
import haquery.server.HaqComponent;
import haquery.server.FileSystem;
import haquery.server.Lib;
using haquery.StringTools;

class HaqPage extends HaqComponent
{
	/**
	 * Default value is "text/html; charset=utf-8".
	 */
    public var contentType = "text/html; charset=utf-8";
    
    /**
     * Last unexist URL part will be placed to this var. 
     * For example, if your request "http://site.com/news/123"
     * then pageID will be "123".
     */
    public var pageID(default, null) : String;
	
    /**
     * Disable special CSS and JS inserts to your HTML pages.
     */
	public var disableSystemHtmlInserts : Bool;
	
    /**
     * Ajax ? calling server event handler : rendering HTML.
     */
    public var isPostback(default, null) : Bool;
	
	public var ajaxResponse(default, null) : String;
	
	public function new()
	{
		super();
		isPostback = false;
		ajaxResponse = "";
	}
	
	override public function render() : String 
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
			addAjaxResponse("haquery.client.page.redirect('" + url.addcslashes() + "');");
		}
        else
		{
			Lib.setReturnCode(302); // Moved Temporarily
			Lib.setHeader("Location", url);
			Lib.isRedirected = true;
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
			redirect(Lib.getURI());
		}
	}
	
	public inline function addAjaxResponse(jsCode:String) 
	{
		ajaxResponse += jsCode + "\n";
	}
}

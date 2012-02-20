package haquery.server;

import haquery.server.HaqComponent;
import haquery.server.FileSystem;
import haquery.server.HaqXml;

using haquery.StringTools;

class HaqPage extends HaqComponent
{
	/**
	 * Default value is "text/html; charset=utf-8".
	 */
    public var contentType : String;
    
    /**
     * Last unexist URL part will be placed to this var. 
     * For example, if your request "http://site.com/news/123"
     * then pageID will be "123".
     */
    public var pageID : String;
	
    /**
     * Disable special CSS and JS inserts to your HTML pages.
     */
	public var disableSystemHtmlInserts : Bool;
	
	public function new() : Void
	{
		super();
		
		contentType = "text/html; charset=utf-8";
	}
    
	override public function render():String 
	{
        forEachComponent('preRender');
		
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
        var text = Lambda.map(links, function(path) return getStyleLink(path)).join('\n        ');
        var heads = doc.find(">html>head");
        if (heads.length > 0)
        {
            var head : HaqXmlNodeElement = heads[0];
            var child : HaqXmlNodeElement = null;
            if (head.children.length > 0)
            {
                child = head.children[0];
                while (child != null && child.name != 'link' && (child.getAttribute('rel') != 'stylesheet' || child.getAttribute('type') != 'text/css'))
                {
                    child = child.getNextSiblingElement();
                }
            }
            head.addChild(new HaqXmlNodeText(text + '\n        '), child);
        }
        else
        {
            doc.addChild(new HaqXmlNodeText(text + '\n'));
        }
    }
    
    function insertScripts(links:Array<String>)
    {
        var text = Lambda.map(links, function(path) return getScriptLink(path)).join('\n        ');
        var heads = doc.find(">html>head");
        if (heads.length > 0)
        {
            var head : HaqXmlNodeElement = heads[0];
            var child : HaqXmlNodeElement = null;
            if (head.children.length > 0)
            {
                child = head.children[0];
                while (child != null && child.name != 'script')
                {
                    child = child.getNextSiblingElement();
                }
            }
            head.addChild(new HaqXmlNodeText(text + '\n        '), child);
        }
        else
        {
            doc.addChild(new HaqXmlNodeText(text + '\n'));
        }
    }
    
    function insertInitBlock(text:String)
    {
        var bodyes = doc.find(">html>body");
        if (bodyes.length > 0)
        {
            var body = bodyes[0];
            body.addChild(new HaqXmlNodeText("\n        " + text.replace('\n', '\n        ') + '\n    '));
        }
        else
        {
            doc.addChild(new HaqXmlNodeText("\n" + text + '\n'));
        }
    }
    
    function getScriptLink(url:String) : String
    {
		if (url.startsWith("<")) return url;
		
		if (!url.startsWith("http://") && !url.startsWith("/"))
		{
			url = '/' + url + '?' + FileSystem.stat(url).mtime.getTime() / 1000;
		}
		return "<script src='" + url + "'></script>";
    }
    
	function getStyleLink(url:String) : String
    {
		if (url.startsWith("<")) return url;
		
		if (!url.startsWith("http://") && !url.startsWith("/"))
		{
			url = '/' + url + '?' + FileSystem.stat(url).mtime.getTime() / 1000;
		}
        return "<link rel='stylesheet' type='text/css' href='" + url + "' />";
    }
}

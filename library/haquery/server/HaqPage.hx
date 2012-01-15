package haquery.server;

import php.Lib;
import php.FileSystem;
import haquery.server.HaqComponent;
import haquery.server.HaqXml;
using haquery.StringTools;

class HaqPage extends HaqComponent
{
	/**
	 * Default value is "text/html; charset=utf-8".
	 */
    public var contentType : String;
    
    /**
     * Last unexist URL part was placed in that var. 
     * For example, if requested URL is "http://site.com/news/123"
     * then pageID will be "123".
     */
    public var pageID : String;
	
	public function new() : Void
	{
		super();
		
		contentType = "text/html; charset=utf-8";
	}
    
    public function insertStyles(links:Array<String>)
    {
        var text = Lambda.map(links, function(path) return getStyleLink(path)).join('\n        ');
        var heads = Lib.toHaxeArray(doc.find(">html>head"));
        if (heads.length > 0)
        {
            var head : HaqXmlNodeElement = heads[0];
            var child : HaqXmlNodeElement = null;
            var children = Lib.toHaxeArray(head.children);
            if (children.length > 0)
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
    
    public function insertScripts(links:Array<String>)
    {
        var text = Lambda.map(links, function(path) return getScriptLink(path)).join('\n        ');
        var heads = Lib.toHaxeArray(doc.find(">html>head"));
        if (heads.length > 0)
        {
            var head : HaqXmlNodeElement = heads[0];
            var child : HaqXmlNodeElement = null;
            var children = Lib.toHaxeArray(head.children);
            if (children.length > 0)
            {
                child = head.children[0];
                while (child != null && child.name != 'script')
                {
                    child = child.getNextSiblingElement();
                }
            }
            head.addChild(new HaqXmlNodeText('    ' + text + '\n    '), child);
        }
        else
        {
            doc.addChild(new HaqXmlNodeText(text + '\n'));
        }
    }
    
    public function insertInitInnerBlock(text:String)
    {
        var bodyes = Lib.toHaxeArray(doc.find(">html>body"));
        if (bodyes.length > 0)
        {
            var body : HaqXmlNodeElement = bodyes[0];
            body.addChild(new HaqXmlNodeText("\n        " + text.replace('\n', '\n        ') + '\n    '));
        }
        else
        {
            doc.addChild(new HaqXmlNodeText("\n" + text + '\n'));
        }
    }
    
    static function getScriptLink(url:String) : String
    {
		if (url.startsWith("<")) return url;
		
		if (!url.startsWith("http://") && !url.startsWith("/"))
		{
			url = '/' + url + '?' + FileSystem.stat(url).mtime.getTime() / 1000;
		}
		return "<script src='" + url + "'></script>";
    }
    
	static function getStyleLink(url:String) : String
    {
		if (url.startsWith("<")) return url;
		
		if (!url.startsWith("http://") && !url.startsWith("/"))
		{
			url = '/' + url + '?' + FileSystem.stat(url).mtime.getTime() / 1000;
		}
        return "<link rel='stylesheet' type='text/css' href='" + url + "' />";
    }
    
}

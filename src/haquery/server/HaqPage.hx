package haquery.server;

import php.Lib;
import php.FileSystem;
import haquery.server.HaqComponent;
import haquery.server.HaqXml;

/**
 * Базовый класс для страниц.
 */
class HaqPage extends HaqComponent
{
	/**
	 * Default value is "text/html; charset=utf-8".
	 */
    public var contentType : String;
    
    /**
     * Last unexist URL part was placed in that var.
     */
    public var pageID : String;
	
	public function new() : Void
	{
		super();
		
		contentType = "text/html; charset=utf-8";
	}
    
    public function insertStyles(links:Array<String>)
    {
        var text = Lambda.map(links, function(path:String):String { return getStyleLink(path); } ).join('\n        ');
        var heads = Lib.toHaxeArray(doc.find(">html>head"));
        if (heads.length == 0)
        {
            throw "HaqPage.insertStyles(): head tag not found.";
        }
        var head : HaqXmlNodeElement = heads[0];
        var child : HaqXmlNodeElement = head.children[0];
        while (child != null && child.name != 'link' && (child.getAttribute('rel') != 'stylesheet' || child.getAttribute('type') != 'text/css'))
        {
            child = child.getNextSiblingElement();
        }
        head.addChild(new HaqXmlNodeText(text + '\n        '), child);
    }
    
    public function insertScripts(links:Array<String>)
    {
        var text = Lambda.map(links, function(path:String):String { return getScriptLink(path); } ).join('\n        ');
        var heads = Lib.toHaxeArray(doc.find(">html>head"));
        if (heads.length == 0)
        {
            throw "HaqPage.insertScripts(): head tag not found.";
        }
        var head : HaqXmlNodeElement = heads[0];
        var child : HaqXmlNodeElement = head.children[0];
        while (child != null && child.name != 'script')
        {
            child = child.getNextSiblingElement();
        }
        head.addChild(new HaqXmlNodeText('    ' + text + '\n    '), child);
    }
    
    public function insertInitInnerBlock(text:String)
    {
        var bodyes = Lib.toHaxeArray(doc.find(">html>body"));
        if (bodyes.length == 0)
        {
            throw "HaqPage.insertInitInnerBlock(): body tag not found.";
        }
        var body : HaqXmlNodeElement = bodyes[0];
        body.addChild(new HaqXmlNodeText("\n        " + text.replace('\n', '\n        ') + '\n    '));
    }
    
    static function getScriptLink(path:String) : String
    {
        var url = '/' + path + '?' + FileSystem.stat(path).mtime.getTime()/1000;
        return "<script src='" + url + "'></script>";
    }
    
	static function getStyleLink(path:String) : String
    {
        var url = '/' + path + '?' + FileSystem.stat(path).mtime.getTime()/1000;
        return "<link rel='stylesheet' type='text/css' href='" + url + "' />";
    }
    
}

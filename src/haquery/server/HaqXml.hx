package haquery.server;

import php.Lib;
import php.NativeArray;
import php.Serializable;
import haquery.server.HaqComponent;

extern class HaqXmlNode implements Serializable
{
	public var parent(default,null) : HaqXmlNodeElement;
    
    public function remove() : Void;
    
	public function getPrevSiblingNode() : HaqXmlNode;
    public function getNextSiblingNode() : HaqXmlNode;
    
    public function getPrevSiblingElement() : HaqXmlNodeElement;
    public function getNextSiblingElement() : HaqXmlNodeElement;
	
    public function serialize() : String;
    public function unserialize(serialized : String) : Void;
}

extern class HaqXmlNodeElement extends HaqXmlNode
{
	public var innerHTML : String;
	
	public var name : String;
    public var nodes : NativeArray; // Array<HaqXmlNode>;
	public var children : NativeArray; //Array<HaqXmlNodeElement>;
    public var component : HaqComponent;

    public function new(name : String, attributes : NativeArray) : Void;
    public function addChild(node : HaqXmlNode) : Void;
    public function __toString() : String;
    override public function serialize() : String;
    override public function unserialize(serialized : String) : Void;
    public function getAttribute(name:String) : String;
    public function setAttribute(name:String, value:Dynamic) : Void;
    public function removeAttribute(name:String) : Void;
    public function hasAttribute(name:String) : Bool;
    
	/**
	 * 
	 * @param	selector
	 * @return Array<HaqXmlNodeElement>
	 */
	public function find(selector : String) : NativeArray;
    public function replaceChild(node:HaqXmlNode, newNode:HaqXmlNode) : Void;
    public function replaceChildWithInner(node:HaqXmlNode, nodeContainer:HaqXmlNodeElement) : Void;
    public function removeChild(node:HaqXmlNode) : Void;
    //public function getAttributesAssoc() : Hash<String>;
    public function getAttributesAssoc() : NativeArray;
    public function setInnerText(text : String) : Void;
}

extern class HaqXml extends HaqXmlNodeElement
{
    static function __init__() : Void
	{
		untyped __php__("require_once dirname(__FILE__) . '/HaqXml.php';");
	}
    
	public function new(str:String = '') : Void;
	
	public function toString() : String;
}

extern class HaqXmlNodeText extends HaqXmlNode
{
    public var text : String;

    public function new(text:String) : Void;
    public function __toString() : String;
    override public function serialize() : String;
    override public function unserialize(serialized:String) : Void;
}

extern class HaqXmlAttribute
{
    public var name : String;
    public var value : String;
    public var quote : String;

    public function new(name:String, value:String, quote:String) : Void;
    public function __toString() : String;
}

extern class HaqXmlParser
{
	static public function parse(str : String) : NativeArray;
}

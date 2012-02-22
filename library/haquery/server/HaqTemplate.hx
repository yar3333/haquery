package haquery.server;

import haxe.Serializer;
import haxe.Unserializer;

class HaqTemplate extends haquery.base.HaqTemplate
{
	var parser : HaqTemplateParser;
	
	public var extend(default, null) : String;
	
	var serializedDoc(default, null) : String;
	
	public var css(default, null) : String;
	public var serverClassName(default, null) : String;
	public var serverHandlers(default, null) : Hash<Array<String>>;
	
	public var lastMod : Date;
	
	public function new(fullTag:String) 
	{
		parser = new HaqTemplateParser(fullTag);
		
		super(fullTag, parser.getImports());
		
		extend = parser.getExtend();
		
		var docAndCss = parser.getDocAndCss();
		serializedDoc = docAndCss.doc.serialize();
		css = docAndCss.css;
		
		serverClassName = parser.getClassName();
		serverHandlers = parser.getServerHandlers(serverClassName);
	}
	
	public function getDocCopy() : HaqXml
	{
		return Unserializer.run(serializedDoc);
	}
	
	public function getSupportFilePath(relPath:String)
	{
		return parser.getSupportFilePath(relPath);
	}
	
	public function serialize() : String
	{
		var ser = new Serializer();
		ser.useCache = true;
		ser.serialize(this);
		return ser.toString();
	}
}
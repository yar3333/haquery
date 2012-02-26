package haquery.server;

import haquery.Serializer;
import haquery.Unserializer;

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
		parser = new HaqTemplateParser(fullTag, []);
		
		super(fullTag, parser.getImports());
		
		extend = parser.getExtend();
		
		var docAndCss = parser.getDocAndCss();
		serializedDoc = serializeDoc(docAndCss.doc);
		css = docAndCss.css;
		
		serverClassName = parser.getClassName();
		serverHandlers = parser.getServerHandlers(serverClassName);
	}
	
	function serializeDoc(doc:HaqXml) : String
	{
		return Serializer.run(doc);
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
		return Serializer.run(this);
	}
	
	public static function unserialize(s:String) : HaqTemplate
	{
		return Unserializer.run(s);
	}
}
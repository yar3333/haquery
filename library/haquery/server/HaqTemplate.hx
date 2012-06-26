package haquery.server;

import haxe.Serializer;
import haxe.Unserializer;
import haxe.htmlparser.HtmlDocument;

class HaqTemplate extends haquery.base.HaqTemplate
{
	var parser : HaqTemplateParser;
	
	public var extend(default, null) : String;
	
	var serializedDoc(default, null) : String;
	
	public var css(default, null) : String;
	public var serverClassName(default, null) : String;
	public var serverHandlers(default, null) : Hash<Array<String>>;
	
	public function new(fullTag:String) 
	{
		if (Lib.config.isTraceComponent)
		{
			trace("Parse '" + fullTag + "' component");
		}
		
		parser = new HaqTemplateParser(fullTag, []);
		
		super(fullTag, parser.getImports());
		
		extend = parser.getExtend();
		
		var docAndCss = parser.getDocAndCss();
		serializedDoc = serializeDoc(docAndCss.doc);
		css = docAndCss.css;
		
		serverClassName = parser.getClassName();
		serverHandlers = parser.getServerHandlers(serverClassName);
	}
	
	function serializeDoc(doc:HtmlDocument) : String
	{
		return Serializer.run(doc);
	}
	
	public function getDocCopy() : HtmlDocument
	{
		Lib.profiler.begin("getDocCopy");
		var doc = Unserializer.run(serializedDoc);
		Lib.profiler.end();
		return doc;
	}
	
	public function getSupportFilePath(relPath:String)
	{
		return parser.getSupportFilePath(relPath);
	}
}
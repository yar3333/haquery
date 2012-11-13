package haquery.server;

import haxe.Serializer;
import haxe.Unserializer;
import haxe.htmlparser.HtmlDocument;

class HaqTemplate extends haquery.base.HaqTemplate
{
	var parser : HaqTemplateParser;
	
	public var extend(default, null) : String;
	public var imports(default, null) : Array<{ component:String, asTag:String }>;
	
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
		
		super(fullTag);
		
		extend = parser.getExtend();
		imports = parser.getImports();
		
		var docAndCss = parser.getDocAndCss();
		serializedDoc = Serializer.run(docAndCss.doc);
		css = docAndCss.css;
		
		serverClassName = parser.getClassName();
		serverHandlers = parser.getServerHandlers(serverClassName);
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
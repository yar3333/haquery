package haquery.server;

class HaqTemplate 
{
	var parser : HaqTemplateParser;
	
	public var fullTag(fullTag_getter, null) : String;
	
	public var doc(default, null) : HaqXml;
	public var css(default, null) : String;
	public var serverClass(default, null) : Class<HaqComponent>;
	public var serverHandlers(default, null) : Hash<Array<String>>;
	public var imports(default, null) : Array<String>;
	
	public function new(fullTag:String) 
	{
		parser = new HaqTemplateParser(fullTag);
		
		var docAndCss = parser.getDocAndCss();
		doc = docAndCss.doc;
		css = docAndCss.css;
		
		serverClass = parser.getClass();
		serverHandlers = parser.getServerHandlers(serverClass);
		
		imports = parser.getImports();
	}
	
	public function getSupportFilePath(relPath:String)
	{
		return parser.getSupportFilePath(relPath);
	}
	
	public inline function fullTag_getter() : String
	{
		return parser.getFullTag();
	}
}
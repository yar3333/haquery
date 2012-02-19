package haquery.server;

class HaqTemplate extends haquery.base.HaqTemplate
{
	var parser : HaqTemplateParser;
	
	public var extend(default, null) : String;
	
	public var doc(default, null) : HaqXml;
	public var css(default, null) : String;
	public var serverClassName(default, null) : String;
	public var serverHandlers(default, null) : Hash<Array<String>>;
	
	public var lastTemplateDocModified : Date;
	public var lastServerCodeModified : Date;
	public var lastClientCodeModified : Date;
	
	public function new(fullTag:String) 
	{
		parser = new HaqTemplateParser(fullTag);
		
		super(fullTag, parser.getImports());
		
		extend = parser.getExtend();
		
		var docAndCss = parser.getDocAndCss();
		doc = docAndCss.doc;
		css = docAndCss.css;
		
		serverClassName = parser.getClassName();
		serverHandlers = parser.getServerHandlers(serverClassName);
	}
	
	public function getSupportFilePath(relPath:String)
	{
		return parser.getSupportFilePath(relPath);
	}
}
package haquery.server;

import haquery.server.template_parsers.ITemplateParser;

class HaqTemplate 
{
	var parser : ITemplateParser;
	
	public var doc(default, null) : HaqXml;
	public var css(default, null) : String;
	public var serverClass(default, null) : Class<HaqComponent>;
	public var serverHandlers(default, null) : Hash<Array<String>>;
	
	public var collection(default, null) : String;
	public var extendsCollection(default, null) : String;
	
	public function new(parser:ITemplateParser) 
	{
		this.parser = parser;
		
		var docAndCss = parser.getDocAndCss();
		doc = docAndCss.doc;
		css = docAndCss.css;
		
		serverHandlers = parser.getServerHandlers();
		serverClass = parser.getServerClass();
		
		collection = parser.getCollectionName();
		extendsCollection = parser.getExtendsCollectionName();
	}
	
	public function getSupportFilePath(relPath:String)
	{
		return parser.getSupportFilePath(relPath);
	}
}
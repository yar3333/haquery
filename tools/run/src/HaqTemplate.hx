package ;

import haxe.htmlparser.HtmlDocument;

class HaqTemplate extends haquery.base.HaqTemplate
{
	public var doc(default, null) : HtmlDocument; 
	
	public var serverClassName(default, null) : String;
	public var clientClassName(default, null) : String;
	
	public var hasLocalServerClass(default, null) : Bool;
	public var hasLocalClientClass(default, null) : Bool;
		
	public var genTemplateServerFilePath(default, null) : String;
	public var genTemplateClientFilePath(default, null) : String;
	
	public var genBaseServerFilePath(default, null) : String;
	public var genBaseClientFilePath(default, null) : String;
	
	public var baseServerClass : String;
	public var baseClientClass : String;
	
	public var lastMod(default, null) : Date;
	public var requires(default, null) : Array<String>;
	public var extend(default, null) : String;
	
	public function new(classPaths:Array<String>, fullTag:String) 
	{
		var parser = new HaqTemplateParser(classPaths, fullTag, []);
		
		super(fullTag, parser.getImports());
		
		doc = parser.getDocAndCss().doc;
		
		serverClassName = parser.getServerClassName();
		clientClassName = parser.getClientClassName();
		
		hasLocalServerClass = parser.hasLocalServerClass();
		hasLocalClientClass = parser.hasLocalClientClass();
		
		var genFolder = parser.getGenFolder();
		
		genTemplateServerFilePath = genFolder + "TemplateServer.hx";
		genTemplateClientFilePath = genFolder + "TemplateClient.hx";
		genBaseServerFilePath = genFolder + "BaseServer.hx";
		genBaseClientFilePath = genFolder + "BaseClient.hx";
		baseServerClass = parser.getBaseServerClass();
		baseClientClass = parser.getBaseClientClass();
		
		lastMod = parser.getLastMod();
		requires = parser.getRequires();
		extend = parser.getExtend();
	}
}

package haquery.tools;

import haxe.htmlparser.HtmlDocument;

class HaqTemplate extends haquery.base.HaqTemplate
{
	public var doc(default, null) : HtmlDocument; 
	
	public var serverClassName(default, null) : String;
	public var clientClassName(default, null) : String;
	
	public var hasLocalServerClass(default, null) : Bool;
	public var hasLocalClientClass(default, null) : Bool;
		
	public var trmServerFilePath(default, null) : String;
	public var trmClientFilePath(default, null) : String;
	
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
		
		trmServerFilePath = parser.getTrmServerFilePath();
		trmClientFilePath = parser.getTrmClientFilePath();
		
		lastMod = parser.getLastMod();
		requires = parser.getRequires();
		extend = parser.getExtend();
	}
}

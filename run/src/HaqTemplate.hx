package ;

import hant.Log;
import htmlparser.HtmlDocument;
import haxe.Serializer;
import haxe.Unserializer;

class HaqTemplate extends haquery.base.HaqTemplate
{
	public var doc(default, null) : HtmlDocument;
	public var cssBlocks(default, null) : Array<String>;
	
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
	
	public var extend(default, null) : String;
	public var imports(default, null) : Array<{ component:String, asTag:String }>;
	public var requires(default, null) : Array<String>;
	
	public function new(log:Log, classPaths:Array<String>, fullTag:String, basePage:String, staticUrlPrefix:String, substitutes:Array<{ from:EReg, to:String }>)
	{
		super(fullTag);

		var parser = new HaqTemplateParser(log, classPaths, fullTag, [], basePage, staticUrlPrefix, substitutes);
		
		var docAndCss = parser.getDocAndCss();
		doc = docAndCss.doc;
		cssBlocks = docAndCss.cssBlocks;
		
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
		
		extend = parser.getExtend();
		imports = parser.getImports();
		requires = parser.getRequires();
	}
	
	public function getDocCopy()
	{
		return Unserializer.run(Serializer.run(doc));
	}
}

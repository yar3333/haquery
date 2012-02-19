package haquery.tools;

import haquery.server.HaqXml;

class HaqTemplate extends haquery.base.HaqTemplate
{
	public var doc(default, null) : HaqXml; 
	public var docLastMod(default, null) : Date;
	
	public var serverClassName(default, null) : String;
	public var clientClassName(default, null) : String;
	
	public var hasLocalServerClass(default, null) : Bool;
	public var hasLocalClientClass(default, null) : Bool;
		
	public var trmFilePath(default, null) : String;
	
	public function new(classPaths:Array<String>, fullTag:String) 
	{
		var parser = new HaqTemplateParser(classPaths, fullTag);
		
		super(fullTag, parser.getImports());
		
		doc = parser.getDocAndCss().doc;
		docLastMod = parser.getDocLastMod();
		
		serverClassName = parser.getServerClassName();
		clientClassName = parser.getClientClassName();
		
		hasLocalServerClass = parser.hasLocalServerClass();
		hasLocalClientClass = parser.hasLocalClientClass();
		
		trmFilePath = parser.getTrmFilePath();
	}
}

package haquery.tools;

class HaqTemplate extends haquery.base.HaqTemplate
{
	public var docText(default, null) : String; 
	public var docLastMod(default, null) : Date;
	
	public var serverClassName(default, null) : String;
	public var clientClassName(default, null) : String;
	
	public var hasLocalServerClass(default, null) : Bool;
	public var hasLocalClientClass(default, null) : Bool;
		
	public var trmSuperClassName(default, null) : String;
	public var trmFilePath(default, null) : String;
	
	public function new(classPaths:Array<String>, fullTag:String) 
	{
		var parser = new HaqTemplateParser(classPaths, fullTag);
		
		super(parser.getImports());
		
		var docTextAndLastMod = parser.getDocTextAndLastMod();
		docText = docTextAndLastMod.text;
		docLastMod = docTextAndLastMod.lastMod;
		
		serverClassName = parser.getServerClassName();
		clientClassName = parser.getClientClassName();
		
		hasLocalServerClass = parser.hasLocalServerClass();
		hasLocalClientClass = parser.hasLocalClientClass();
		
		trmSuperClassName = parser.getTrmSuperClassName();
		trmFilePath = parser.getTrmFilePath();
	}
}

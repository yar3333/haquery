package haquery.tools;

class HaqTemplate extends haquery.base.HaqTemplate
{
	public var docText(default, null) : String; 
	public var docLastMod : Date;
	public var superTemplateClassName(default, null) : String;
	public var serverClassName(default, null) : String;
	public var clientClassName(default, null) : String;
	
	public function new(classPaths:Array<String>, fullTag:String) 
	{
		var parser = new HaqTemplateParser(classPaths, fullTag);
		
		super(parser.getImports());
		
		var docTextAndLastMod = parser.getDocTextAndLastMod();
		docText = docTextAndLastMod.text;
		docLastMod = docTextAndLastMod.lastMod;
		
		superTemplateClassName = parser.getSuperTemplateClassName();
		serverClassName = parser.getServerClassName();
		clientClassName = parser.getClientClassName();
	}	
}

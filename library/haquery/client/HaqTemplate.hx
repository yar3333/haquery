package haquery.client;

class HaqTemplate extends haquery.base.HaqTemplate
{ 
	public var clientClassName(default, null) : String;
	public var serverHandlers(default, null) : Array<String>;
	
	public function new(fullTag:String)
	{
		var parser = new HaqTemplateParser(fullTag);
		
		super(fullTag);
		
		clientClassName = parser.getClassName();
		serverHandlers = parser.getServerHandlers();
	}
}

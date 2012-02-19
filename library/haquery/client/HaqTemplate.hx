package haquery.client;

class HaqTemplate extends haquery.base.HaqTemplate
{ 
	public var clientClass(default, null) : Class<HaqComponent>;
	
	/**
	 * elemID => handlers
	 */
	public var serverHandlers(default, null) : Hash<Array<String>>;
	
	public function new(fullTag:String)
	{
		var parser = new HaqTemplateParser(fullTag);
		
		super(fullTag, parser.getImports());
		
		clientClass = parser.getClass();
		serverHandlers = parser.getServerHandlers();
	}
}

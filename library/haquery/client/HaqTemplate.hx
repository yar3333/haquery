package haquery.client;

class HaqTemplate extends haquery.base.HaqTemplate
{ 
	public var clientClassName(default, null) : String;
	
	/**
	 * elemID => handlers
	 */
	public var serverHandlers(default, null) : Hash<Array<String>>;
	
	public function new(fullTag:String)
	{
		var parser = new HaqTemplateParser(fullTag);
		
		super(fullTag);
		
		clientClassName = parser.getClassName();
		serverHandlers = parser.getServerHandlers();
	}
}

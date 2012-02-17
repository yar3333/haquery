package haquery.client;

class HaqTemplate extends haquery.base.HaqTemplate
{ 
	public var clientClass(default, null) : Class<HaqComponent>;
	
	/**
	 * elemID => handlers
	 */
	public var serverHandlers(default, null) : Hash<Array<String>>;
	
	public function new(imports:Array<String>, clientClassName:String)
	{
		super(imports);
		this.clientClass = Type.resolveClass(clientClassName);
	}
}

package haquery.client;

class HaqTemplate extends haquery.base.HaqTemplate
{ 
	public var clientClassName(default, null) : String;
	public var serverHandlers(default, null) : Array<String>;
	
	public function new(fullTag:String)
	{
		super(fullTag);
		
		var config = new HaqTemplateConfig(fullTag);
		
		clientClassName = config.clientClassName;
		serverHandlers = config.serverHandlers;
	}
}

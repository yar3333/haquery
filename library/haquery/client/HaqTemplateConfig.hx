package haquery.client;

import haquery.common.HaqTemplateExceptions;

class HaqTemplateConfig
{
	public var clientClassName(default, null) : String;
	public var serverHandlers(default, null) : Array<String>;
	
	public function new(fullTag:String)
	{
		var clas = Type.resolveClass(fullTag + ".ConfigClient");
		if (clas == null)
		{
			throw new HaqTemplateNotFoundException("Component not found [ " + fullTag + " ].");
		}
		
		clientClassName = Reflect.field(clas, "clientClassName");
		var getServerHandlers = Reflect.field(clas, "getServerHandlers");
		serverHandlers = getServerHandlers != null ? Reflect.callMethod(clas, getServerHandlers, []) : [];
	}
}

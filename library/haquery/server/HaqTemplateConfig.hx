package haquery.server;

import haquery.common.HaqTemplateExceptions;

class HaqTemplateConfig
{
	public var extend(default, null) : String;
	public var serverClassName(default, null) : String;
	public var serializedDoc(default, null) : String;
	
	public function new(fullTag:String)
	{
		var clas = Type.resolveClass(fullTag + ".ConfigServer");
		if (clas == null)
		{
			throw new HaqTemplateNotFoundException("Component not found [ " + fullTag + " ].");
		}
		extend = Reflect.field(clas, "extend");
		serverClassName = Reflect.field(clas, "serverClassName");
		serializedDoc = Reflect.field(clas, "serializedDoc");
	}
}

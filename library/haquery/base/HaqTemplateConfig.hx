package haquery.base;

class HaqTemplateConfig
{
	public var extend : String;
	public var imports : Array<String>;
	
	public function new()
	{
		extend = null;
		imports = [];
	}
}

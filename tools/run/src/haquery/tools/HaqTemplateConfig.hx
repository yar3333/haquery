package haquery.tools;

class HaqTemplateConfig extends haquery.server.HaqTemplateConfig
{
    public var force : Array<String>;
	
	public function new()
	{
		super();
		force = [];
	}
}

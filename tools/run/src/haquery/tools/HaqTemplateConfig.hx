package haquery.tools;

class HaqTemplateConfig extends haquery.server.HaqTemplateConfig
{
    public var requires : Array<String>;
	
	public function new()
	{
		super();
		requires = [];
	}
}

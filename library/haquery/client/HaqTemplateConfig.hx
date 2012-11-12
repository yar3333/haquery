package haquery.client;

class HaqTemplateConfig extends haquery.base.HaqTemplateConfig
{
	public function new(extend:String, imports:Array<String>)
	{
		this.extend = extend;
		this.imports = imports;
	}
}

package haquery.base;

class HaqTemplateConfig
{
	public var extend(default, null) : String;
	
	public function new(extend:String)
	{
		this.extend = extend;
	}
}

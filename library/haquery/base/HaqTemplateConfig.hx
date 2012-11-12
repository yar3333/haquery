package haquery.base;

class HaqTemplateConfig
{
	public var extend(default, null) : String;
	public var imports(default, null) : Array<String>;
	
	public function new(extend:String, imports:Array<String>)
	{
		this.extend = extend;
		this.imports = imports;
	}
}

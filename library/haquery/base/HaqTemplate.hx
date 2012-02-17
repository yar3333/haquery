package haquery.base;

class HaqTemplate 
{
	public var imports(default, null) : Array<String>;
	
	public function new(imports:Array<String>)
	{
		this.imports = imports;
	}
}
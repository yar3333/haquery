package haquery.base;

class HaqTemplate 
{
	public var fullTag(default, null) : String;
	public var imports(default, null) : Array<String>;
	
	public function new(fullTag:String, imports:Array<String>)
	{
		this.fullTag = fullTag;
		this.imports = imports;
	}
}
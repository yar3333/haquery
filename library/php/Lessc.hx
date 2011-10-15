package php;

@:native("Lessc") extern class Lessc
{
    static function __init__() : Void
    {
		untyped __php__("require_once 'php/Lessc.php';");
    }

	public function new(?fname:String) : Void;
    /*
     * Parse and compile buffer.
     */
    public function parse(str:String=null) : String;
	
    public static function ccompile(inFile:String, outFile:String) : Void;
}
package js.ckeditor;

typedef CKEditorOptions = {
	var toolbar : Array<Array<String>>;
	var skin : String;
	var scayt_autoStartup : Bool;
	var extraPlugins : String;
	var saveFunction : String -> Void;
	var closeFunction : Void -> Void;
    var resize_enabled: Bool;
}

@:native("CKEDITOR") extern class CKEditor
{
    static function __init__() : Void
	{
		untyped __php__("require_once 'php/FirePHP.php';");
	}
	
	public var config : CKEditorOptions;
	public static function replace(elemID:String, options:CKEditorOptions);
}
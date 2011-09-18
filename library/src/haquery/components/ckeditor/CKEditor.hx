package haquery.components.ckeditor;

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
	public var config : CKEditorOptions;
	
	public static function replace(elemID:String, options:CKEditorOptions) : CKEditor;
	
	public function getData() : String;
	public function setData(text:String) : Void;
}
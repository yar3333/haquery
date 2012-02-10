package haquery.components.ckeditor;

typedef CKEditorOptions = {
	var toolbar : Array<Array<String>>;
	var skin : String;
	var scayt_autoStartup : Bool;
    var resize_enabled: Bool;
	var extraPlugins : String;
}

@:native("CKEDITOR") extern class CKEditor
{
	public var config : CKEditorOptions;
	
	public static function replace(elemID:String, options:CKEditorOptions) : CKEditor;
	
	public function getData() : String;
	public function setData(text:String) : Void;
	
    public function checkDirty() : Bool;
    public function resetDirty() : Void;
    
    public function on(event:String, f:Dynamic->Void) : Void;
}
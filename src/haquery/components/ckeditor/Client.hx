package haquery.components.ckeditor;

class Client extends haquery.client.HaqComponent
{
    private var editor;
    
	public var event_save : HaqEvent;
    public var event_close : HaqEvent;

    public function init()
    {
        editor = CKEDITOR.replace(q('#e')[0].id, {
            toolbar: [
                ['Source'], ['AjaxSave'], ['Undo','Redo','-','Cut','Copy','Paste','PasteText','PasteFromWord'], ['Find','Replace'], ['Styles'], ['Print'], ['Maximize','Close'], '/',
                ['Font','FontSize'], ['NumberedList','BulletedList'], ['Outdent','Indent','Blockquote'], ['Format'], ['BGColor'], '/',
                ['Bold','Italic','Underline','Strike','-','Subscript','Superscript','-','RemoveFormat','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'], ['Link','Unlink','Anchor'], ['Image','Flash','Table','HorizontalRule','Smiley','SpecialChar','PageBreak'], ['TextColor']
            ],
            skin: 'office2003',
            scayt_autoStartup: false,
            extraPlugins: "ajaxsave",
            saveFunction: function(text) { event_save.call(text); },
            closeFunction: function() { event_close.call(); },
            resize_enabled: false
        });
        editor.config.saveFunction = function() { event_save.call(); };
    }

    public var text(text_getter, text_setter) : String;
	
	function text_getter(t) : String
    {
        return editor.getData();
    }
	
	function text_setter(t:String) : Void
    {
        editor.setData(t);
    }
}

package haquery.components.ckeditor;

import haquery.base.HaqEvent;

class Client extends haquery.client.HaqComponent
{
    private var editor : CKEditor;
    
	public var event_save : HaqEvent;
    public var event_close : HaqEvent;

    public var text(text_getter, text_setter) : String;
	function text_getter() : String { return editor.getData(); }
	function text_setter(t:String) : String { editor.setData(t); return t; }
    
	public function init()
    {
        var self = this;
		editor = CKEditor.replace(q('#e')[0].id, {
            toolbar: [
                ['Source'], ['AjaxSave'], ['Undo','Redo','-','Cut','Copy','Paste','PasteText','PasteFromWord'], ['Find','Replace'], ['Styles'], ['Print'], ['Maximize','Close'], '/',
                ['Font','FontSize'], ['NumberedList','BulletedList'], ['Outdent','Indent','Blockquote'], ['Format'], ['BGColor'], '/',
                ['Bold','Italic','Underline','Strike','-','Subscript','Superscript','-','RemoveFormat','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'], ['Link','Unlink','Anchor'], ['Image','Flash','Table','HorizontalRule','Smiley','SpecialChar','PageBreak'], ['TextColor']
            ],
            skin: 'office2003',
            scayt_autoStartup: false,
            extraPlugins: "ajaxsave",
            saveFunction: function(text:String):Void { self.event_save.call([text]); },
            closeFunction: function() { self.event_close.call(); },
            resize_enabled: false
        });
    }
}

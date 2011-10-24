package haquery.components.ckeditor;

import haquery.client.HaqEvent;

class Client extends haquery.client.HaqComponent
{
    var editor : CKEditor;
    
	var event_save : HaqEvent;
    var event_close : HaqEvent;

    public var text(text_getter, text_setter) : String;
	function text_getter() : String { return editor.getData(); }
	function text_setter(t:String) : String { editor.setData(t); return t; }
    
	function init()
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
            saveFunction: function(text:String):Void 
            {
                if (self.event_save.call([text]) == false) return;
                self.q('#t').val(text);
                self.q('#b').click();
            },
            closeFunction: function() 
            { 
                self.event_close.call([text]);
            },
            resize_enabled: false
        });
    }
}

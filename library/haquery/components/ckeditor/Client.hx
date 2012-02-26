package haquery.components.ckeditor;

import haquery.client.HaqComponent;
import haquery.client.HaqEvent;
import haquery.client.Lib;
import haxe.Timer;

class Client extends HaqComponent
{
    var editor : CKEditor;

    public var text(text_getter, text_setter) : String;
	function text_getter() : String { return editor.getData(); }
	function text_setter(t:String) : String { editor.setData(t); return t; }
    
	function init()
    {
		var ta = q('#e');
        if (ta.length > 0)
        {
            editor = CKEditor.replace(ta[0].id, {
                toolbar: [
                    ['Source'], ['Undo','Redo','-','Cut','Copy','Paste','PasteText','PasteFromWord'], ['Find','Replace'], ['Styles'], ['Print'], ['Maximize'], '/',
                    ['Font','FontSize'], ['NumberedList','BulletedList'], ['Outdent','Indent','Blockquote'], ['Format'], ['BGColor'], '/',
                    ['Bold','Italic','Underline','Strike','-','Subscript','Superscript','-','RemoveFormat','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'], ['Link','Unlink','Anchor'], ['Image','Flash','Table','HorizontalRule','Smiley','SpecialChar','PageBreak'], ['TextColor']
                ],
                skin: 'office2003',
                scayt_autoStartup: false,
                resize_enabled: false,
                extraPlugins: ""
            });
            
            var time = new Timer(100);
            time.run = function()
            {
                if (editor.checkDirty())
                {
                    q('#e').html(editor.getData());
                    editor.resetDirty();
                }
            };
        }
    }
}

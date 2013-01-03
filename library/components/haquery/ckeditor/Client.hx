package components.haquery.ckeditor;

import haquery.common.HaqEvent;
import haxe.Timer;

class Client extends BaseClient
{
    var editor : CKEditor;

    public var text(getText, setText) : String;
	function getText() : String { return editor.getData(); }
	function setText(t:String) : String { editor.setData(t); return t; }
    
	function init()
    {
		var ta = q('#e');
        if (ta.length > 0)
        {
            editor = CKEditor.replace(ta[0].id, cast {
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

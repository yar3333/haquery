package haquery.components.codemirror;

import haquery.client.HaQuery;
import jQuery.JQuery;
import js.Lib;
import haquery.client.HaqEvent;
import haquery.client.HaqComponent;

class Client extends HaqComponent
{
    var editor : CodeMirror;
    
    public var event_save : HaqEvent;

    public function init()
    {
        var text = StringTools.unescape(q('#text').val());
        q('#text').val(text);

        var mode = q('#editor').attr('mode');
        if (mode=='htmlmixed')
        {
            loadCssFile('mode/xml/xml.css');
            loadCssFile('mode/css/css.css');
            loadCssFile('mode/javascript/javascript.css');
            loadCssFile('mode/clike/clike.css');
        }
        else if (mode=='css')
        {
            loadCssFile('mode/css/css.css');
        }
        else if (mode=='javascript')
        {
            loadCssFile('mode/javascript/javascript.css');
        }
        else if (mode=='php')
        {
            loadCssFile('mode/clike/clike.css');
        }
        else if (mode=='clike')
        {
            loadCssFile('mode/clike/clike.css');
        }

        var editable : String = q('#editor').attr('editable');

        var self = this;

        this.editor = CodeMirror.create(q('#editor')[0],
        {
            mode: mode,
            indentUnit: 4,
            value: text,
            readOnly : editable=='' || editable.toLowerCase()=='false' || editable=='0',
            onChange: function()
            {
                if (self.editor!=null) self.q('#text').val(self.editor.getValue());
            },
            saveFunction: function()
            {
                self.q('#text').val(self.getValue());
                self.event_save.call([self]);
            }
        });

        new JQuery(Lib.window).keydown(function(event) : Bool
        {
            if (!self.hasFocus()) return true;
            if ((event.ctrlKey || event.metaKey) && !event.altKey)
            {
                if (event.keyCode == 83)
                {
                    self.q('#text').val(self.getValue());
                    self.event_save.call([self]);
                    return false;
                }
            }
            return true;
        });
    }

    public function height(height:Int) : Void
    {
        q('#editor .CodeMirror').height(height);
    }

    public function getValue() : String
    {
        return editor.getValue(); 
    }
    
    public function setValue(text:String) : Void
    {
        editor.setValue(text); 
    }

    public function focus() : Void
    {
        editor.focus();
    }

    public function hasFocus() : Bool
    {
        return new JQuery(this.editor.getWrapperElement()).hasClass('CodeMirror-focused');
    }

    function loadCssFile(filename:String) : Void
    {
        filename = '/' + Type.getClassName(Type.getClass(this)).replace('.', '/') + '/' + HaQuery.folders.support + '/' + filename;
        trace('filename to load = ' + filename);

        var fileref = Lib.document.createElement("link");
        new JQuery(fileref)
            .attr("rel", "stylesheet")
            .attr("type", "text/css")
            .attr("href", filename);

        Lib.document.getElementsByTagName("head")[0].appendChild(fileref);
    }

    public function refresh() : Void
    {
        if (editor != null) editor.refresh();
    }

    public function isLoaded() : Bool
    {
        return this.editor != null;
    }
}

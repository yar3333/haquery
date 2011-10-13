package haquery.components.codemirror;

import js.Lib;
import haquery.client.Lib;
import haquery.client.HaqQuery;
import haquery.client.HaqEvent;
import haquery.client.HaqComponent;

class Client extends HaqComponent
{
    var editor : CodeMirror;
    
    var event_save : HaqEvent;

    function init()
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
        editor = CodeMirror.create(q('#editor').get(0),
        {
            mode: mode,
            indentUnit: 4,
            value: text,
            readOnly : editable == null || editable == '' || editable.toLowerCase() == 'false' || editable == '0',
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

        new HaqQuery(Lib.window).keydown(function(event) : Bool
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
        return new HaqQuery(this.editor.getWrapperElement()).hasClass('CodeMirror-focused');
    }
    
    function loadCssFile(filename:String) : Void
    {
        var path = manager.getSupportUrl(tag) + filename;
        trace('filename to load = ' + path);
        var fileref = Lib.document.createElement("link");
        new HaqQuery(fileref)
            .attr("rel", "stylesheet")
            .attr("type", "text/css")
            .attr("href", path);

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

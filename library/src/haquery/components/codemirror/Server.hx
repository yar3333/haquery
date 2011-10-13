package haquery.components.codemirror;

import haquery.server.HaqComponent;
import haquery.server.Lib;
using haquery.StringTools;

class Server extends HaqComponent
{
    public var mode : String;
    public var text : String;
    public var cssClass : String;
    public var editable : Bool;
    public var customData : Dynamic;

    public function new()
    {
        super();
        
        mode = 'htmlmixed';
        text = null;
        cssClass = '';
        editable = false;
        customData = null;
    }
    
    function init() : Void
    {
        if (!isPostback)
        {
            if (text==null) text = StringTools.htmlUnescape(innerHTML);
        }
        else
        {
            text = this.q('#text').val();
            customData = StringTools.jsonDecode(StringTools.unescape(q('#customData').val()));
        }
    }

    function preRender() : Void
    {
        manager.registerScript(tag, 'lib/codemirror.js');
        if (mode == 'htmlmixed')
        {
            manager.registerScript(tag, 'mode/htmlmixed/htmlmixed.js');
            manager.registerScript(tag, 'mode/xml/xml.js');
            manager.registerScript(tag, 'mode/javascript/javascript.js');
            manager.registerScript(tag, 'mode/css/css.js');
        }
        else if (mode=='css')
        {
            manager.registerScript(tag, 'mode/css/css.js');
        }
        else if (mode=='javascript')
        {
            manager.registerScript(tag, 'mode/javascript/javascript.js');
        }
        else if (mode=='php')
        {
            manager.registerScript(tag, 'mode/clike/clike.js');
            manager.registerScript(tag, 'mode/php/php.js');
        }
        else if (mode=='clike')
        {
            manager.registerScript(tag, 'mode/clike/clike.js');
        }
        
        q('#customData').val(StringTools.escape(StringTools.jsonEncode(customData)));

        q('#editor').attr('mode', mode);
        if (this.editable) q('#editor').attr('editable', 'true');
        else               q('#editor').removeAttr('editable');
        q('#text').val(StringTools.escape(text.trim()));

        if (cssClass!='') q('#editor').addClass(cssClass);
    }
}

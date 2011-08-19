package haquery.components.codemirror;

import haquery.server.HaqComponent;
import haquery.server.HaQuery;

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
        editable = true;
        customData = null;
    }
    
    public function init() : Void
    {
        if (!HaQuery.isPostback)
        {
            if (text==null) text = StringTools.htmlUnescape(innerHTML);
        }
        else
        {
            text = this.q('#text').val();
            customData = StringTools.jsonDecode(StringTools.unescape(q('#customData').val()));
        }
    }

    public function preRender() : Void
    {
        manager.registerScript(tag, 'lib/codemirror.js');
        if (mode == 'htmlmixed')
        {
            manager.registerScript(tag, 'mode/htmlmixed/htmlmixed.js');
            manager.registerScript(tag, 'mode/xml/xml.js');
            manager.registerScript(tag, 'mode/javascript/javascript.js');
            manager.registerScript(tag, 'mode/css/css.js');
        }
        
        q('#customData').val(StringTools.escape(StringTools.jsonEncode(customData)));

        q('#editor').attr('mode', mode);
        if (this.editable) q('#editor').attr('editable', 'true');
        else               q('#editor').removeAttr('editable');
        q('#text').val(StringTools.escape(text.trim()));

        if (cssClass!='') q('#editor').addClass(cssClass);
    }
}

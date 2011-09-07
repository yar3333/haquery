package haquery.components.uploader;

import haquery.client.HaqElemEventManager;
import haquery.client.HaqEvent;
import haquery.client.HaqQuery;
import jQuery.JQuery;
import js.Dom;

class Client extends Base
{
    var event_select : HaqEvent;
    var event_filterNotMatch : HaqEvent;
    var event_uploading : HaqEvent;
    var event_complete : HaqEvent;

    public function init()
    {
        q("#file").attr("name", q("#file").get(0).id);
    }

    public function container_mousemove(t, e)
    {
        if (!enabled) return;
        
        var container = q('#container');
        var file = q('#file');
        var offset = container.offset();
        
        q('#file').offset({
            left: Math.min(offset.left + container.width() - file.width(), Math.max(offset.left, e.pageX - 50)),
            top:  Math.min(offset.top + container.height() - file.height(), Math.max(offset.top,  e.pageY - 10))
        });
    }

    public function file_mousemove(t, e)
    {
        container_mousemove(t, e);
    }
    
    public function file_change() : Bool
    {
        var fileName : String = q('#file').val();
        var filter = q('#filter').val();
        if (filter != '')
        {
            var re = new EReg(filter, "");
            if (!re.match(fileName))
            {
                event_filterNotMatch.call([fileName]);
                return false;
            }
        }

        if (!event_select.call([fileName])) return false;

        event_uploading.call();
        enabled = false;

        var frame : IFrame = q('#frame').get(0);
        new HaqQuery(frame).unbind('load').load(function() {
            var elem : HtmlDom = frame.contentWindow.document.body.firstChild;
            var text = elem.innerHTML;
            HaqElemEventManager.callServerHandlersCallbackFunction(text); 
        });
        
        var form : HaqQuery = q('#form');
        var sendData = HaqElemEventManager.getDataObjectForSendToServer(q('#file').get(0).id, 'upload');
        for (key in Reflect.fields(sendData))
        {
            form.append("<input type='hidden' id='HAQUERY_ID-" + key + "' name='" + key + "' />\n");
            (new JQuery('#HAQUERY_ID-' + key)).val(Reflect.field(sendData, key));
        }
        form.get(0).submit();
        
        for (key in Reflect.fields(sendData))
        {
            if (key != prefixID + 'file')
            {
                (new JQuery('#HAQUERY_ID-' + key)).remove();
            }
        }
        
        return true;
    }
    
    public function fileUploadComplete(errorCode:Int)
    {
        enabled = true;
        event_complete.call([errorCode]);
    }
}
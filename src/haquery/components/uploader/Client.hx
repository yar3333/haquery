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
        
        q('#file').css({
            top: e.pageY - 5 + 'px',
            left: e.pageX - 50 + 'px'
        });
    }

    public function file_change() : Bool
    {
        q('#file').val();

        var filter = q('#filter').val();
        if (filter != '')
        {
            var re = new EReg(filter, "");
            if (!re.match(q('#file').val()))
            {
                event_filterNotMatch.call();
                return false;
            }
        }

        if (!event_select.call(q('#file').val())) return false;

        event_uploading.call();
        enabled = false;

        var frame : IFrame = q('#frame').get(0);
        new HaqQuery(frame).load(function() {
            var elem : HtmlDom = frame.contentWindow.document.body.firstChild;
            var text = elem.innerHTML;
            js.Lib.alert("Loaded text = " + text);  
            HaqElemEventManager.callServerHandlersCallbackFunction(text); 
        });
        
        var form : HaqQuery = q('#form');
        var sendData = HaqElemEventManager.getDataObjectForSendToServer(q('#file').get(0).id, 'upload');
        for (key in Reflect.fields(sendData))
        {
            form.append("<input type='hidden' id='" + key + "' name='" + key + "' />\n");
            (new JQuery('#' + key)).val(Reflect.field(sendData, key));
        }
        form.get(0).submit();
        
        for (key in Reflect.fields(sendData))
        {
            if (key != prefixID + 'file')
            {
                (new JQuery('#' + key)).remove();
            }
        }
        
        return true;
    }
    
    public function fileUploadComplete(errorCode:Int)
    {
        event_complete.call([errorCode]);
    }
}
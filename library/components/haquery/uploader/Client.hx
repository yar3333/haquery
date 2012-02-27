package components.haquery.uploader;

import haquery.client.HaqElemEventManager;
import haquery.client.HaqEvent;
import haquery.client.HaqQuery;
import js.JQuery;
import js.Dom;

using haquery.StringTools;

class Client extends Base
{
    var event_select : HaqEvent;
    var event_filterNotMatch : HaqEvent;
    var event_uploading : HaqEvent;
    var event_complete : HaqEvent;

    function init()
    {
        q("#file").attr("name", q("#file")[0].id);
    }

    function container_mousemove(t, e)
    {
        if (!enabled) return;
        
        var container = q('#container');
        var file = q('#file');
        var offset = container.offset();
        
        q('#file').offset({
            left: Std.int(Math.min(offset.left + container.width() - file.width(), Math.max(offset.left, e.pageX - 50))),
            top:  Std.int(Math.min(offset.top + container.height() - file.height(), Math.max(offset.top,  e.pageY - 10)))
        });
    }

    function file_mousemove(t, e)
    {
        container_mousemove(t, e);
    }
    
    function file_change() : Bool
    {
        var fileName : String = q('#file').val();
        fileName = fileName.replace('\\', '/');
        if (fileName.lastIndexOf('/') > 0)
        {
            fileName = fileName.substr(fileName.lastIndexOf('/') + 1);
        }
        
        var filter = q('#filter').val();
        if (filter != '')
        {
            var re = new EReg(filter, "i");
            if (!re.match(fileName))
            {
                event_filterNotMatch.call([fileName]);
                return false;
            }
        }

        if (!event_select.call([fileName])) return false;

        event_uploading.call();
        enabled = false;

        var frame : IFrame = cast q('#frame')[0];
        new JQuery(frame).unbind('load').load(function(e:JqEvent) {
            var elem : HtmlDom = frame.contentWindow.document.body.firstChild;
            var text = elem.innerHTML;
            HaqElemEventManager.callServerHandlersCallbackFunction(text); 
        });
        
        var form : HaqQuery = q('#form');
        var sendData = HaqElemEventManager.getDataObjectForSendToServer(fullID, 'upload');
        for (key in Reflect.fields(sendData))
        {
            form.append("<input type='hidden' id='HAQUERY_DATA-" + key + "' name='" + key + "' />\n");
            (new JQuery('#HAQUERY_DATA-' + key)).val(Reflect.field(sendData, key));
        }
        cast(form[0]).submit();
        
        for (key in Reflect.fields(sendData))
        {
            if (key != prefixID + 'file')
            {
                (new JQuery('#HAQUERY_DATA-' + key)).remove();
            }
        }
        
        return true;
    }
    
    function fileUploadComplete(errorCode:Int)
    {
        enabled = true;
        event_complete.call([errorCode]);
    }
}
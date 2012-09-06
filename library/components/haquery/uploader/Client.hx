package components.haquery.uploader;

import haquery.client.HaqElemEventManager;
import haquery.common.HaqEvent;
import haquery.client.HaqQuery;
import js.JQuery;
import js.Dom;

using haquery.StringTools;

class Client extends Base
{
    var event_select : HaqEvent<{ fileName:String }>;
    var event_filterNotMatch : HaqEvent<{ fileName:String }>;
    var event_uploading : HaqEvent<Dynamic>;
    var event_complete : HaqEvent<{ errorCode:Int }>;

    function init()
    {
        q("#file").attr("name", q("#file")[0].id);
    }

    function container_mousemove(t, e)
    {
        if (!enabled) return;
        
        var container = q("#container");
        var file = q("#file");
        var offset = container.offset();
        
        q("#file").offset({
            left: Std.int(Math.min(offset.left + container.width() - file.width(), Math.max(offset.left, e.pageX - 50))),
            top:  Std.int(Math.min(offset.top + container.height() - file.height(), Math.max(offset.top,  e.pageY - 10)))
        });
    }

    function file_mousemove(t, e)
    {
        container_mousemove(t, e);
    }
    
    function file_change(t, e) : Bool
    {
        var fileName : String = q("#file").val();
        fileName = fileName.replace("\\", "/");
        if (fileName.lastIndexOf("/") > 0)
        {
            fileName = fileName.substr(fileName.lastIndexOf('/') + 1);
        }
        
        var filter = q("#filter").val();
        if (filter != "")
        {
            var re = new EReg(filter, "i");
            if (!re.match(fileName))
            {
                event_filterNotMatch.call({ fileName:fileName });
                return false;
            }
        }

        if (!event_select.call({ fileName:fileName })) return false;

        event_uploading.call(null);
        enabled = false;

        var frame : IFrame = cast q("#frame")[0];
        q(frame).unbind("load").load(function(e:JqEvent) 
		{
            var text = frame.contentWindow.document.body.firstChild.innerHTML;
            HaqElemEventManager.callServerHandlersCallbackFunction(text, function(e:{ errorCode:Int })
			{
				enabled = true;
				event_complete.call(e);
			}); 
        });
        
		var form : HaqQuery = q("#form");
        var sendData = HaqElemEventManager.getDataObjectForSendToServer(fullID, "upload");
        for (key in Reflect.fields(sendData))
        {
            form.append("<input type='hidden' id='HAQUERY_DATA-" + key + "' name='" + key + "' />\n");
            new JQuery("#HAQUERY_DATA-" + key).val(Reflect.field(sendData, key));
        }
        cast(form[0]).submit();
        
        for (key in Reflect.fields(sendData))
        {
            if (key != prefixID + "file")
            {
                new JQuery("#HAQUERY_DATA-" + key).remove();
            }
        }
        
        return true;
    }
}
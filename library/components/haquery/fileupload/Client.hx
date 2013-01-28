package components.haquery.fileupload;

import haquery.client.HaqElemEventManager;
import haquery.common.HaqEvent;
import haquery.common.HaqUploadResult;
import haquery.client.HaqQuery;
import haxe.Unserializer;
import js.JQuery;
import js.Dom;

using haquery.StringTools;

class Client extends Base
{
    var event_select : HaqEvent<{ fileName:String }>;
    var event_filterNotMatch : HaqEvent<{ fileName:String }>;
    var event_uploading : HaqEvent<Dynamic>;
    var event_complete : HaqEvent<HaqUploadResult>;

    function init()
    {
        template().file.attr("name", template().file[0].id);
    }

	function container_click(_, _)
	{
		template().file.click();
	}
    
	function file_change(t, e) : Bool
    {
        var fileName : String = template().file.val();
        fileName = fileName.replace("\\", "/");
        if (fileName.lastIndexOf("/") > 0)
        {
            fileName = fileName.substr(fileName.lastIndexOf('/') + 1);
        }
        
        var filter = template().frame.data("filter");
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

        var frame : IFrame = cast template().frame[0];
		q(frame).unbind("load").load(function(e:JqEvent) 
		{
            var text = frame.contentWindow.document.body.firstChild.innerHTML;
			enabled = true;
			event_complete.call(Unserializer.run(text));
        });
        
        cast(template().form[0]).submit();
        
        return true;
    }
}
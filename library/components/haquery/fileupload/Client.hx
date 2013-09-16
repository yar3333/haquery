package components.haquery.fileupload;

import js.html.IFrameElement;
import haquery.common.HaqEvent;
import haquery.common.HaqUploadResult;
import haquery.client.HaqQuery;
import haxe.Unserializer;
import js.JQuery;
using stdlib.StringTools;

class Client extends Base
{
    /**
     * Fires when user select file to upload. You can return false from the handler if you want to disable uploading.
     */
	var event_select : HaqEvent<{ fileName:String }>;
    
	var event_uploading : HaqEvent<Dynamic>;
    
	var event_complete : HaqEvent<{ uploads:HaqUploadResult }>;

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
        
        if (!event_select.call({ fileName:fileName })) return false;

        event_uploading.call(null);
        enabled = false;

        var frame : IFrameElement = cast template().frame[0];
		q(frame).unbind("load").load(function(e:JqEvent) 
		{
            var text = (cast frame.contentWindow.document.body.firstChild).innerHTML;
			enabled = true;
			event_complete.call({ uploads:Unserializer.run(text) });
        });
        
        cast(template().form[0]).submit();
        
        return true;
    }
}
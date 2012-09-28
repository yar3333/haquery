package components.haquery.uploader;

import haquery.server.Lib;
import haquery.common.HaqEvent;

class Server extends Base
{
    public var filter : String;
    
	var event_upload : HaqEvent<{ file:haquery.server.HaqUploadedFile }>;

    function preRender()
    {
        q("#form").attr("target", prefixID + "frame");
        q("#frame").attr("name", prefixID + "frame");
        q("#filter").val(filter);
    }
    
    @shared function upload() : { errorCode:Int }
    {
		var file = page.uploadedFiles.get(prefixID + "file");
		var customResult = new Hash<Dynamic>();
        event_upload.call({ file:file });
        return { errorCode:Type.enumIndex(file.error) };
    }
}

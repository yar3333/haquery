package components.haquery.uploader;

import haquery.server.HaqEvent;
import haquery.server.Web;

typedef UploadEventArgs = 
{
	var file : haquery.server.UploadedFile;
}

class Server extends Base
{
    public var filter : String;
    
	var event_upload : HaqEvent<UploadEventArgs>;

    function preRender()
    {
        q('#form').attr('target', prefixID + 'frame');
        q('#frame').attr('name', prefixID + 'frame');
        q('#filter').val(filter);
    }
    
    @shared function upload()
    {
        var files = Web.getUploadedFiles(50 * 1024 * 1024);
		var file = files.get(prefixID + 'file');
        event_upload.call({ file:file });
        callSharedMethod('fileUploadComplete', [ Type.enumIndex(file.error) ]);
    }
}

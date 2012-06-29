package components.haquery.uploader;

import haquery.server.Lib;
import haquery.common.HaqEvent;

typedef UploadEventArgs = 
{
	var file : haquery.server.HaqUploadedFile;
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
		var file = Lib.uploadedFiles.get(prefixID + 'file');
        event_upload.call({ file:file });
        callSharedMethod('fileUploadComplete', [ Type.enumIndex(file.error) ]);
    }
}

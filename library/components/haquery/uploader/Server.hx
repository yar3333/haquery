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
        #if php
		var files = Web.getFiles();
        var file = files.get(prefixID + 'file');
        event_upload.call({ file:file });
        callSharedMethod('fileUploadComplete', [ Type.enumIndex(file.error) ]);
		#elseif neko
        // TODO: neko file uploading
		callSharedMethod('fileUploadComplete', [ -1 ]);
		#end
    }
}

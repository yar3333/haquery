package haquery.components.uploader;

import haquery.server.HaqEvent;
import haquery.server.Web;

class Server extends Base
{
    public var filter : String;
    var event_upload : HaqEvent;

    function preRender() : Void
    {
        q('#form').attr('target', prefixID + 'frame');
        q('#frame').attr('name', prefixID + 'frame');
        q('#filter').val(filter);
    }
    
    @shared function upload()
    {
        var files = Web.getFiles();
        var file = files.get(prefixID + 'file');
        event_upload.call([file]);
        callClientMethod('fileUploadComplete', [Type.enumIndex(file.error) ]);
    }
}

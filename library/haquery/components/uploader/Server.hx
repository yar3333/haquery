package haquery.components.uploader;

import haquery.server.HaqComponent;
import haquery.server.HaqComponentManager;
import haquery.server.HaqEvent;
import haquery.server.HaqTools;
import haquery.server.Lib;
import haquery.server.HaqXml;
import php.FileSystem;
import php.Session;
import php.Web;
import php.Lib;

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
    
    function file_upload()
    {
        var files = Web.getFiles();
        var file = files.get(prefixID + 'file');
        event_upload.call([file]);
        callClientMethod('fileUploadComplete', [Type.enumIndex(file.error) ]);
    }
}
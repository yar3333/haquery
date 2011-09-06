package haquery.components.uploader;

import haquery.server.HaqEvent;
import haquery.server.HaqTools;
import haquery.server.HaQuery;
import php.FileSystem;
import php.Session;
import php.Web;
import php.Lib;

class Server extends Base
{
    public var filter : String;
    
    public var event_upload : HaqEvent;
    
    override function getHeader() : String 
    {
        return '<form id="form" method="post" enctype="multipart/form-data" class="uploader" style="display:block">
    <input type="file" id="file" size="1" class="uploader-file" />
    <div id="container" class="uploader-container">
';
    }
    
    override function getFooter() : String 
    {
        return '
    </div>
</form>
<input type="hidden" id="filter" />
<iframe id="frame" src="about:blank" style="display:none;"></iframe>
';
    }

    public function preRender() : Void
    {
        q('#form').attr('target', prefixID + 'frame');
        q('#frame').attr('name', prefixID + 'frame');
        q('#filter').val(filter);
    }
    
    public function file_upload()
    {
        var files = Web.getFiles();
        var file = files.get(prefixID + 'file');
        event_upload.call([file]);
        callClientMethod('fileUploadComplete', [Type.enumIndex(file.error) ]);
    }
}

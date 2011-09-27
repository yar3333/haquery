package haquery.components.uploader;

import haquery.server.HaqComponent;
import haquery.server.HaqComponentManager;
import haquery.server.HaqEvent;
import haquery.server.HaqTools;
import haquery.server.HaQuery;
import haquery.server.HaqXml;
import php.FileSystem;
import php.Session;
import php.Web;
import php.Lib;

class Server extends Base
{
    public var filter : String;
    
    var event_upload : HaqEvent;
    
    override public function construct(manager:HaqComponentManager, parent:HaqComponent, tag:String, id:String, doc:HaqXml, params:Dynamic, innerHTML:String) : Void
	{
        super.construct(manager, parent, tag, id, new HaqXml(getHeader() + innerHTML + getFooter()), params, '');
	}
    
    function getHeader() : String 
    {
        return '<form id="form" method="post" enctype="multipart/form-data" class="uploader" style="display:block">
    <input type="file" id="file" size="1" class="uploader-file" />
    <div id="container" class="uploader-container">
';
    }
    
    function getFooter() : String 
    {
        return '
    </div>
</form>
<input type="hidden" id="filter" />
<iframe id="frame" src="about:blank" style="display:none;"></iframe>
';
    }

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

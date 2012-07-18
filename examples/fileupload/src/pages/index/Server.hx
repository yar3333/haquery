package pages.index;

import haquery.server.HaqPage;
import haxe.io.Path;

class Server extends HaqPage
{
    function fu_upload(t, e:components.haquery.uploader.Server.UploadEventArgs)
    {
        q('#status').html("upload " + e.file.name);
        e.file.move('uploads/' + Path.withoutDirectory(e.file.name));
    }
}